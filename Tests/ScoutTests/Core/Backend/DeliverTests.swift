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
    let cloud2 = InMemoryDatabase()
    let server = InMemoryDatabase()
    let context = NSManagedObjectContext.inMemoryContext()

    var cloudBackend: Backend {
        Backend(
            id: "cloud",
            database: cloud,
            checkAvailability: { true },
            displayName: "cloud",
            aggregator: cloud
        )
    }

    var cloud2Backend: Backend {
        Backend(
            id: "cloud2",
            database: cloud2,
            checkAvailability: { true },
            displayName: "cloud2",
            aggregator: cloud2
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

    /// Run both engines for a type the way `synchronize` does: raw records first, then matrices.
    func deliver<T: Syncable & MatrixBatch & RecordEncodable>(_ type: T.Type, to backend: Backend) async throws {
        try await RecordSender(backend: backend, context: context).deliver(type: type)
        try await MatrixSender(backend: backend, context: context)?.deliver(type: type)
    }

    @Test("Events go raw to every backend, matrices only to CloudKit")
    func eventsFanOut() async throws {
        EventObject.stub(name: "login", in: context)
        try context.save()
        try SyncableObject.plan(backends: backends, in: context)

        for backend in backends {
            try await deliver(EventObject.self, to: backend)
        }

        #expect(cloud.records.filter { $0.recordType == "Event" }.count == 1)
        #expect(server.records.filter { $0.recordType == "Event" }.count == 1)
        #expect(cloud.records.filter { $0.recordType == Int.recordType }.count == 1)
        #expect(server.records.filter { $0.recordType == Int.recordType }.count == 0)
    }

    @Test("Metrics go raw to servers and as matrices to CloudKit")
    func metricsSplit() async throws {
        IntMetricsObject.stub(name: "requests", telemetry: "counter", value: 5, in: context)
        try context.save()
        try SyncableObject.plan(backends: backends, in: context)

        for backend in backends {
            try await deliver(IntMetricsObject.self, to: backend)
        }

        #expect(server.records.filter { $0.recordType == "IntMetric" }.count == 1)
        #expect(cloud.records.filter { $0.recordType == "IntMetric" }.count == 0)
        #expect(cloud.records.filter { $0.recordType == Int.recordType }.count == 1)
        #expect(server.records.filter { $0.recordType == Int.recordType }.count == 0)
    }

    @Test("A server-only setup skips the matrix stage entirely")
    func serverOnly() async throws {
        let event = EventObject.stub(name: "login", in: context)
        try context.save()
        try SyncableObject.plan(backends: [serverBackend], in: context)

        try await deliver(EventObject.self, to: serverBackend)

        #expect(event.delivery(for: "server")?.isDelivered == true)
        #expect(server.records.filter { $0.recordType == "Event" }.count == 1)
        #expect(server.records.filter { $0.recordType == Int.recordType }.isEmpty)
    }

    @Test("A failing backend leaves its row outstanding without blocking the others")
    func failureIsolatedToBackend() async throws {
        let event = EventObject.stub(name: "login", in: context)
        try context.save()
        try SyncableObject.plan(backends: backends, in: context)

        server.writeErrors.append(NSError(domain: "TestError", code: 1))

        // The CloudKit engine succeeds independently of the failing server engine.
        try await deliver(EventObject.self, to: cloudBackend)
        await #expect(throws: (any Error).self) {
            try await deliver(EventObject.self, to: serverBackend)
        }

        #expect(event.delivery(for: "cloud")?.isDelivered == true)
        #expect(event.delivery(for: "server")?.progress == [.raw])
        #expect(event.delivery(for: "server")?.attempts == 1)
        #expect(cloud.records.filter { $0.recordType == "Event" }.count == 1)
        #expect(server.records.filter { $0.recordType == "Event" }.count == 0)
    }

    @Test("An unavailable backend is left untouched without blocking the others")
    func unavailableBackendIsSkipped() async throws {
        let event = EventObject.stub(name: "login", in: context)
        try context.save()
        try SyncableObject.plan(backends: backends, in: context)

        // The server is unavailable this cycle, so only its CloudKit engine runs.
        try await deliver(EventObject.self, to: cloudBackend)

        // The server's row is seeded but untouched — not even an attempt is
        // counted — so it is delivered once its engine runs again.
        #expect(event.delivery(for: "cloud")?.isDelivered == true)
        #expect(event.delivery(for: "server")?.progress == [.raw])
        #expect(event.delivery(for: "server")?.attempts == 0)
        #expect(cloud.records.filter { $0.recordType == "Event" }.count == 1)
        #expect(server.records.filter { $0.recordType == "Event" }.count == 0)
    }

    @Test("A matrix is contributed per native backend, never twice")
    func matrixPerNativeBackend() async throws {
        let event = EventObject.stub(name: "login", synced: true, in: context)
        // Prior cycle: the first native backend was fully delivered, the second
        // still owes its matrix.
        event.seedDelivery([], for: "cloud", in: context)
        event.seedDelivery([.matrix], for: "cloud2", in: context)
        try context.save()

        try await deliver(EventObject.self, to: cloudBackend)
        try await deliver(EventObject.self, to: cloud2Backend)

        #expect(event.delivery(for: "cloud")?.isDelivered == true)
        #expect(event.delivery(for: "cloud2")?.isDelivered == true)
        // The first backend's matrix isn't contributed a second time...
        #expect(cloud.records.filter { $0.recordType == Int.recordType }.isEmpty)
        // ...while the second backend's matrix is contributed exactly once.
        #expect(cloud2.records.filter { $0.recordType == Int.recordType }.count == 1)
    }

    @Test("A backend abandoned after too many attempts is no longer retried")
    func abandonedBackendSettles() async throws {
        let event = EventObject.stub(name: "login", synced: true, in: context)
        event.seedDelivery([.raw, .matrix], for: "cloud", in: context)
        // The server is already at the attempt ceiling and still owes its raw record.
        event.seedDelivery([.raw], attempts: Int16(SyncDelivery.maxAttempts), for: "server", in: context)
        try context.save()

        try await deliver(EventObject.self, to: cloudBackend)
        try await deliver(EventObject.self, to: serverBackend)

        #expect(event.delivery(for: "cloud")?.isDelivered == true)
        #expect(event.delivery(for: "server")?.isAbandoned == true)
        // The abandoned server is never written to.
        #expect(server.records.filter { $0.recordType == "Event" }.isEmpty)
    }

    @Test("The recovered backend is retried alone; healthy ones aren't rewritten")
    func resumesWithoutRewritingHealthyBackends() async throws {
        let event = EventObject.stub(name: "login", in: context)
        try context.save()
        try SyncableObject.plan(backends: backends, in: context)

        // First cycle: the server is down, CloudKit succeeds.
        server.writeErrors.append(NSError(domain: "TestError", code: 1))
        try await deliver(EventObject.self, to: cloudBackend)
        await #expect(throws: (any Error).self) {
            try await deliver(EventObject.self, to: serverBackend)
        }

        // Second cycle: only the recovered server engine runs.
        try await deliver(EventObject.self, to: serverBackend)

        #expect(event.delivery(for: "server")?.isDelivered == true)
        #expect(server.records.filter { $0.recordType == "Event" }.count == 1)
        // CloudKit's raw record and matrix were each written exactly once.
        #expect(cloud.records.filter { $0.recordType == "Event" }.count == 1)
        #expect(cloud.records.filter { $0.recordType == Int.recordType }.count == 1)
    }

    @Test("Dropping a never-reached backend lets cleanup reclaim the record")
    func droppingBackendUnblocks() async throws {
        let old = Date(timeIntervalSinceNow: -8 * 86400)
        let event = EventObject.stub(name: "login", date: old, in: context)
        try context.save()
        try SyncableObject.plan(backends: backends, in: context)

        // CloudKit delivered; the server never accepts the record.
        server.writeErrors.append(NSError(domain: "TestError", code: 1))
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
