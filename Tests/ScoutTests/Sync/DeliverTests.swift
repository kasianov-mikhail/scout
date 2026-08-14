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

    /// End a session and requeue it on a private-queue sibling, the way the real
    /// end-of-session write lands on a background context rather than on the one
    /// the delivery engine holds.
    ///
    /// The work stays synchronous on purpose: before the iOS 26 SDK, `perform` is
    /// a plain nonisolated `async` method, so awaiting it from this main-actor
    /// suite sends the context and the closure across isolation and fails to
    /// compile there.
    ///
    func endSessionInBackground(_ sessionID: NSManagedObjectID) throws {
        let background = context.backgroundSibling()

        try background.performAndWait {
            let session = try #require(background.object(with: sessionID) as? SessionEntry)
            session.endDate = Date()
            session.requeue()
            try background.save()
        }
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

    @Test("Transient write failures don't consume the attempt budget")
    func transientFailuresPreserveAttempts() async throws {
        let event = EventEntry.stub(name: "login", in: context)
        try context.save()
        try SyncableEntry.plan(backends: [serverBackend], in: context)

        let flakyServer = Backend(
            id: "server",
            database: server,
            checkAvailability: { true },
            displayName: "server",
            isTransientError: { $0 is URLError }
        )

        // The availability check passes, but every real send fails on connectivity
        // for far longer than the attempt budget would allow...
        for _ in 0..<(DeliveryEntry.maxAttempts * 2) {
            server.writeErrors.append(URLError(.notConnectedToInternet))
            await #expect(throws: (any Error).self) {
                try await deliver(EventEntry.self, to: flakyServer)
            }
        }

        // ...yet not one attempt is spent, so the record is still deliverable.
        #expect(event.delivery(for: "server")?.attempts == 0)
        #expect(event.delivery(for: "server")?.isPending == true)
        #expect(server.records.count(of: "Event") == 0)

        // Connectivity returns and the record delivers on the first real send.
        try await deliver(EventEntry.self, to: flakyServer)
        #expect(event.delivery(for: "server")?.isDelivered == true)
        #expect(server.records.count(of: "Event") == 1)
    }

    @Test("A cancelled send doesn't consume the attempt budget")
    func cancellationPreservesAttempts() async throws {
        let event = EventEntry.stub(name: "login", in: context)
        try context.save()
        try SyncableEntry.plan(backends: [serverBackend], in: context)

        server.writeErrors.append(CancellationError())
        await #expect(throws: (any Error).self) {
            try await deliver(EventEntry.self, to: serverBackend)
        }

        #expect(event.delivery(for: "server")?.attempts == 0)
        #expect(event.delivery(for: "server")?.isPending == true)
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

    @Test("A rejected record burns its own budget, not the whole batch")
    func rejectionIsolatedToRecord() async throws {
        let healthy = (0..<7).map { EventEntry.stub(name: "healthy-\($0)", in: context) }
        let poison = EventEntry.stub(name: "poison", in: context)
        try context.save()
        try SyncableEntry.plan(backends: [serverBackend], in: context)

        // The server refuses one malformed record and accepts everything else.
        server.reject = { $0["name"] as String? == "poison" }

        await #expect(throws: (any Error).self) {
            try await deliver(EventEntry.self, to: serverBackend)
        }

        // The records it was batched with are delivered in the same pass...
        #expect(server.records.count(of: "Event") == 7)
        #expect(healthy.allSatisfy { $0.delivery(for: "server")?.isDelivered == true })

        // ...and only the rejected one pays for the rejection.
        #expect(poison.delivery(for: "server")?.attempts == 1)
        #expect(poison.delivery(for: "server")?.isPending == true)
    }

    @Test("A backend rejecting everything stays within the probe budget")
    func wholesaleRejectionStaysBounded() async throws {
        for index in 0..<64 {
            EventEntry.stub(name: "event-\(index)", in: context)
        }
        try context.save()
        try SyncableEntry.plan(backends: [serverBackend], in: context)

        server.reject = { _ in true }

        await #expect(throws: (any Error).self) {
            try await deliver(EventEntry.self, to: serverBackend)
        }

        // Singling out the culprits costs sends, so one pass is capped instead of
        // fanning a backlog out into a request per record...
        #expect(server.writeCount <= RecordSender.maxProbes)
        #expect(server.records.count(of: "Event") == 0)

        // ...while still making progress: whatever it did single out is charged.
        let charged = try context.fetchAll(EventEntry.self).filter {
            ($0.delivery(for: "server")?.attempts ?? 0) > 0
        }
        #expect(charged.count > 0)
    }

    @Test("A requeue during the send survives the delivery pass")
    func requeueDuringSendStaysPending() async throws {
        let session = SessionEntry.stub(date: Date(), in: context)
        try context.save()
        try SyncableEntry.plan(backends: [cloudBackend], in: context)

        // The session ends while its record is in flight: the completion fills in
        // the end date and requeues the row mid-send.
        cloud.beforeWrite = { @MainActor in
            session.endDate = Date()
            session.requeue()
        }

        try await deliver(SessionEntry.self, to: cloudBackend)
        cloud.beforeWrite = nil

        // The send delivered a stale record, so the row must stay pending...
        #expect(session.delivery(for: "cloud")?.isPending == true)

        // ...and the next pass delivers the completed session.
        try await deliver(SessionEntry.self, to: cloudBackend)

        #expect(session.delivery(for: "cloud")?.isDelivered == true)
        #expect(cloud.records.count(of: "Session") == 2)

        let delivered = try #require(cloud.records.last { $0.recordType == "Session" })
        #expect(delivered["end_date"] as Date? != nil)
    }

    @Test("A requeue on a background context during the send survives the delivery pass")
    func backgroundRequeueDuringSendStaysPending() async throws {
        let session = SessionEntry.stub(date: Date(), in: context)
        try context.save()
        try SyncableEntry.plan(backends: [cloudBackend], in: context)

        let sessionID = session.objectID

        // The session ends mid-send the way it really does — on a background
        // context, not the one the delivery engine holds.
        cloud.beforeWrite = { @MainActor in
            try? self.endSessionInBackground(sessionID)
        }

        try await deliver(SessionEntry.self, to: cloudBackend)
        cloud.beforeWrite = nil

        // The send delivered a stale record, so the row must stay pending...
        #expect(session.delivery(for: "cloud")?.isPending == true)

        // ...and the next pass delivers the completed session.
        try await deliver(SessionEntry.self, to: cloudBackend)

        #expect(session.delivery(for: "cloud")?.isDelivered == true)
        #expect(cloud.records.count(of: "Session") == 2)

        let delivered = try #require(cloud.records.last { $0.recordType == "Session" })
        #expect(delivered["end_date"] as Date? != nil)
    }

    @Test("A requeue on a background context after delivery is picked up by the next pass")
    func backgroundRequeueAfterDeliveryIsResent() async throws {
        let session = SessionEntry.stub(date: Date(), in: context)
        try context.save()
        try SyncableEntry.plan(backends: [cloudBackend], in: context)

        try await deliver(SessionEntry.self, to: cloudBackend)
        #expect(session.delivery(for: "cloud")?.isDelivered == true)

        // The session completes on a background context once the row is already
        // delivered, so only the requeue can bring it back.
        try endSessionInBackground(session.objectID)

        try await deliver(SessionEntry.self, to: cloudBackend)

        #expect(session.delivery(for: "cloud")?.isDelivered == true)
        #expect(cloud.records.count(of: "Session") == 2)

        let delivered = try #require(cloud.records.last { $0.recordType == "Session" })
        #expect(delivered["end_date"] as Date? != nil)
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
