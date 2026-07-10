//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Foundation
import Testing

@testable import Scout

@MainActor
@Suite("Deliver across backends")
struct DeliverTests {
    let cloud = InMemoryDatabase()
    let server = InMemoryDatabase()
    let context = NSManagedObjectContext.inMemoryContext()

    private static let testError = NSError(domain: "TestError", code: 1)

    var cloudBackend: Backend {
        Backend(
            id: "cloud",
            database: cloud,
            checkAvailability: { true },
            displayName: "cloud"
        )
    }

    var serverBackend: Backend {
        Backend(
            id: "server",
            database: server,
            checkAvailability: { true },
            displayName: "server"
        )
    }

    var backends: [Backend] {
        [cloudBackend, serverBackend]
    }

    /// Run the delivery engine for a type the way `synchronize` does: raw records to every backend.
    func deliver<T: SyncableObject & RecordEncodable>(_ type: T.Type, to backend: Backend) async throws {
        SyncDelivery.recordAttempt(for: backend.id, in: context)
        try await RecordSender(backend: backend).deliver(type: type, in: context)
    }

    @Test("Events go raw to every backend")
    func eventsFanOut() async throws {
        EventObject.stub(name: "login", in: context)
        try context.save()
        try SyncableObject.plan(backends: backends, in: context)

        for backend in backends {
            try await deliver(EventObject.self, to: backend)
        }

        #expect(cloud.records.count(of: "Event") == 1)
        #expect(server.records.count(of: "Event") == 1)
    }

    @Test("A failing backend leaves its row outstanding without blocking the others")
    func failureIsolatedToBackend() async throws {
        let event = EventObject.stub(name: "login", in: context)
        try context.save()
        try SyncableObject.plan(backends: backends, in: context)

        server.writeErrors.append(Self.testError)

        // The cloud engine succeeds independently of the failing server engine.
        try await deliver(EventObject.self, to: cloudBackend)
        await #expect(throws: (any Error).self) {
            try await deliver(EventObject.self, to: serverBackend)
        }

        #expect(event.delivery(for: "cloud")?.isDelivered == true)
        #expect(event.delivery(for: "server")?.isPending == true)
        #expect(event.delivery(for: "server")?.attempts == 1)
        #expect(cloud.records.count(of: "Event") == 1)
        #expect(server.records.count(of: "Event") == 0)
    }

    @Test("An unavailable backend is left untouched without blocking the others")
    func unavailableBackendIsSkipped() async throws {
        let event = EventObject.stub(name: "login", in: context)
        try context.save()
        try SyncableObject.plan(backends: backends, in: context)

        // The server is unavailable this cycle, so only the cloud engine runs.
        try await deliver(EventObject.self, to: cloudBackend)

        // The server's row is seeded but untouched — not even an attempt is
        // counted — so it is delivered once its engine runs again.
        #expect(event.delivery(for: "cloud")?.isDelivered == true)
        #expect(event.delivery(for: "server")?.isPending == true)
        #expect(event.delivery(for: "server")?.attempts == 0)
        #expect(cloud.records.count(of: "Event") == 1)
        #expect(server.records.count(of: "Event") == 0)
    }

    @Test("A backend abandoned after too many attempts is no longer retried")
    func abandonedBackendSettles() async throws {
        let event = EventObject.stub(name: "login", synced: true, in: context)
        event.seedDelivery(for: "cloud", in: context)
        // The server is already at the attempt ceiling and still owes its raw record.
        event.seedDelivery(attempts: Int16(SyncDelivery.maxAttempts), for: "server", in: context)
        try context.save()

        try await deliver(EventObject.self, to: cloudBackend)
        try await deliver(EventObject.self, to: serverBackend)

        #expect(event.delivery(for: "cloud")?.isDelivered == true)
        #expect(event.delivery(for: "server")?.isAbandoned == true)
        // The abandoned server is never written to.
        #expect(server.records.count(of: "Event") == 0)
    }

    @Test("The recovered backend is retried alone; healthy ones aren't rewritten")
    func resumesWithoutRewritingHealthyBackends() async throws {
        let event = EventObject.stub(name: "login", in: context)
        try context.save()
        try SyncableObject.plan(backends: backends, in: context)

        // First cycle: the server is down, cloud succeeds.
        server.writeErrors.append(Self.testError)
        try await deliver(EventObject.self, to: cloudBackend)
        await #expect(throws: (any Error).self) {
            try await deliver(EventObject.self, to: serverBackend)
        }

        // Second cycle: only the recovered server engine runs.
        try await deliver(EventObject.self, to: serverBackend)

        #expect(event.delivery(for: "server")?.isDelivered == true)
        #expect(server.records.count(of: "Event") == 1)
        // Cloud's raw record was written exactly once.
        #expect(cloud.records.count(of: "Event") == 1)
    }

    @Test("Dropping a never-reached backend lets cleanup reclaim the record")
    func droppingBackendUnblocks() async throws {
        let old = Date(timeIntervalSinceNow: -8 * 86400)
        let event = EventObject.stub(name: "login", date: old, in: context)
        try context.save()
        try SyncableObject.plan(backends: backends, in: context)

        // Cloud delivered; the server never accepts the record.
        server.writeErrors.append(Self.testError)
        try await deliver(EventObject.self, to: cloudBackend)
        await #expect(throws: (any Error).self) {
            try await deliver(EventObject.self, to: serverBackend)
        }
        #expect(event.delivery(for: "server")?.isDelivered == false)

        // While the server is configured, the outstanding row keeps the record...
        try SyncableObject.cleanup(backends: backends, in: context)
        #expect(try context.fetchAll(EventObject.self).count == 1)

        // ...but once it is dropped from the config, cleanup reclaims it.
        try SyncableObject.cleanup(backends: [cloudBackend], in: context)
        #expect(try context.fetchAll(EventObject.self).isEmpty)
    }
}
