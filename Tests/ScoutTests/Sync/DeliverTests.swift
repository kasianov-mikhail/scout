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
@testable import Support

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

    /// Run the delivery engine for a type the way `synchronize` does: skip an
    /// unavailable backend, otherwise send its raw records and let the send itself
    /// count the attempt on failure.
    func deliver<T: SyncableEntry & RecordEncodable>(_ type: T.Type, to backend: Backend) async throws {
        guard await backend.checkAvailability() else { return }
        try await RecordSender(backend: backend).deliver(type: type, in: context)
    }

    @Test("Events go raw to every backend")
    func eventsFanOut() async throws {
        EventEntry.stub(name: "login", in: context)
        try context.save()
        try SyncableEntry.plan(backends: backends, in: context)

        for backend in backends {
            try await deliver(EventEntry.self, to: backend)
        }

        #expect(cloud.records.count(of: "Event") == 1)
        #expect(server.records.count(of: "Event") == 1)
    }

    @Test("A failing backend leaves its row outstanding without blocking the others")
    func failureIsolatedToBackend() async throws {
        let event = EventEntry.stub(name: "login", in: context)
        try context.save()
        try SyncableEntry.plan(backends: backends, in: context)

        server.writeErrors.append(Self.testError)

        // The cloud engine succeeds independently of the failing server engine.
        try await deliver(EventEntry.self, to: cloudBackend)
        await #expect(throws: (any Error).self) {
            try await deliver(EventEntry.self, to: serverBackend)
        }

        #expect(event.delivery(for: "cloud")?.isDelivered == true)
        #expect(event.delivery(for: "server")?.isPending == true)
        #expect(event.delivery(for: "server")?.attempts == 1)
        #expect(cloud.records.count(of: "Event") == 1)
        #expect(server.records.count(of: "Event") == 0)
    }

    @Test("An unavailable backend is left untouched without blocking the others")
    func unavailableBackendIsSkipped() async throws {
        let event = EventEntry.stub(name: "login", in: context)
        try context.save()
        try SyncableEntry.plan(backends: backends, in: context)

        // The server is unavailable this cycle, so only the cloud engine runs.
        try await deliver(EventEntry.self, to: cloudBackend)

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
        let event = EventEntry.stub(name: "login", synced: true, in: context)
        event.seedDelivery(for: "cloud", in: context)
        // The server is already at the attempt ceiling and still owes its raw record.
        event.seedDelivery(attempts: Int16(DeliveryEntry.maxAttempts), for: "server", in: context)
        try context.save()

        try await deliver(EventEntry.self, to: cloudBackend)
        try await deliver(EventEntry.self, to: serverBackend)

        #expect(event.delivery(for: "cloud")?.isDelivered == true)
        #expect(event.delivery(for: "server")?.isAbandoned == true)
        // The abandoned server is never written to.
        #expect(server.records.count(of: "Event") == 0)
    }

    @Test("The recovered backend is retried alone; healthy ones aren't rewritten")
    func resumesWithoutRewritingHealthyBackends() async throws {
        let event = EventEntry.stub(name: "login", in: context)
        try context.save()
        try SyncableEntry.plan(backends: backends, in: context)

        // First cycle: the server is down, cloud succeeds.
        server.writeErrors.append(Self.testError)
        try await deliver(EventEntry.self, to: cloudBackend)
        await #expect(throws: (any Error).self) {
            try await deliver(EventEntry.self, to: serverBackend)
        }

        // Second cycle: only the recovered server engine runs.
        try await deliver(EventEntry.self, to: serverBackend)

        #expect(event.delivery(for: "server")?.isDelivered == true)
        #expect(server.records.count(of: "Event") == 1)
        // Cloud's raw record was written exactly once.
        #expect(cloud.records.count(of: "Event") == 1)
    }

    @Test("Offline passes cost nothing: an unavailable backend keeps its full budget")
    func offlinePassesPreserveAttempts() async throws {
        let event = EventEntry.stub(name: "login", in: context)
        try context.save()
        try SyncableEntry.plan(backends: backends, in: context)

        let offlineServer = Backend(
            id: "server",
            database: server,
            checkAvailability: { false },
            displayName: "server"
        )

        // Many sync passes fire while the backend is unreachable...
        for _ in 0..<(DeliveryEntry.maxAttempts * 2) {
            try await deliver(EventEntry.self, to: offlineServer)
        }

        // ...yet not one attempt is spent, so the record is still deliverable.
        #expect(event.delivery(for: "server")?.attempts == 0)
        #expect(event.delivery(for: "server")?.isPending == true)
        #expect(server.records.count(of: "Event") == 0)

        // Connectivity returns and the record delivers on the first real send.
        try await deliver(EventEntry.self, to: serverBackend)
        #expect(event.delivery(for: "server")?.isDelivered == true)
        #expect(server.records.count(of: "Event") == 1)
    }

    @Test("A record is retried the full attempt budget before being abandoned")
    func fullAttemptBudget() async throws {
        let event = EventEntry.stub(name: "login", in: context)
        try context.save()
        try SyncableEntry.plan(backends: [serverBackend], in: context)

        // The server rejects every write for the whole attempt budget.
        for _ in 0..<DeliveryEntry.maxAttempts {
            server.writeErrors.append(Self.testError)
        }

        for _ in 0..<DeliveryEntry.maxAttempts {
            await #expect(throws: (any Error).self) {
                try await deliver(EventEntry.self, to: serverBackend)
            }
        }

        // Every attempt in the budget was a real send: the ceiling is reached only
        // after maxAttempts writes, not one short of it.
        #expect(server.writeErrors.isEmpty)
        #expect(event.delivery(for: "server")?.attempts == Int16(DeliveryEntry.maxAttempts))
        #expect(event.delivery(for: "server")?.isAbandoned == true)

        // Once abandoned, no further write is attempted.
        try await deliver(EventEntry.self, to: serverBackend)
        #expect(server.records.count(of: "Event") == 0)
    }

    @Test("A backend added after the first sync still receives one-shot records")
    func lateAddedBackendReceivesOneShots() async throws {
        let old = Date(timeIntervalSinceNow: -8 * 86400)
        DeviceEntry.stub(date: old, in: context)
        try context.save()

        // First cycle: only the cloud is configured; the record delivers and
        // ages past the cleanup window.
        try SyncableEntry.plan(backends: [cloudBackend], in: context)
        try await deliver(DeviceEntry.self, to: cloudBackend)
        try DateEntry.cleanup(backends: [cloudBackend], in: context)

        // Second cycle: the server joins and receives the same record.
        try SyncableEntry.plan(backends: backends, in: context)
        try await deliver(DeviceEntry.self, to: serverBackend)

        #expect(cloud.records.count(of: "Device") == 1)
        #expect(server.records.count(of: "Device") == 1)
    }

    @Test("Dropping a never-reached backend lets cleanup reclaim the record")
    func droppingBackendUnblocks() async throws {
        let old = Date(timeIntervalSinceNow: -8 * 86400)
        let event = EventEntry.stub(name: "login", date: old, in: context)
        try context.save()
        try SyncableEntry.plan(backends: backends, in: context)

        // Cloud delivered; the server never accepts the record.
        server.writeErrors.append(Self.testError)
        try await deliver(EventEntry.self, to: cloudBackend)
        await #expect(throws: (any Error).self) {
            try await deliver(EventEntry.self, to: serverBackend)
        }
        #expect(event.delivery(for: "server")?.isDelivered == false)

        // While the server is configured, the outstanding row keeps the record...
        try DateEntry.cleanup(backends: backends, in: context)
        #expect(try context.fetchAll(EventEntry.self).count == 1)

        // ...but once it is dropped from the config, cleanup reclaims it.
        try DateEntry.cleanup(backends: [cloudBackend], in: context)
        #expect(try context.fetchAll(EventEntry.self).isEmpty)
    }
}
