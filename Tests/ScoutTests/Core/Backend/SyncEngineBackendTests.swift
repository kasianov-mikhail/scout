//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData
import Testing

@testable import Scout

@MainActor
@Suite("SyncEngine with multiple backends")
struct SyncEngineBackendTests {
    let cloud = InMemoryDatabase()
    let server = InMemoryDatabase()
    let context = NSManagedObjectContext.inMemoryContext()

    var cloudBackend: ResolvedBackend {
        ResolvedBackend(
            id: "cloud",
            database: cloud,
            needsClientAggregation: true,
            acceptsRawMetrics: false,
            checkAvailability: {}
        )
    }

    var serverBackend: ResolvedBackend {
        ResolvedBackend(
            id: "server",
            database: server,
            needsClientAggregation: false,
            acceptsRawMetrics: true,
            checkAvailability: {}
        )
    }

    var backends: [ResolvedBackend] {
        [cloudBackend, serverBackend]
    }

    @Test("Events go raw to every backend, matrices only to CloudKit")
    func eventsFanOut() async throws {
        EventObject.stub(name: "login", in: context)
        try context.save()

        let engine = SyncEngine(backends: backends, context: context)
        try await engine.send(type: EventObject.self)

        #expect(cloud.records.filter { $0.recordType == "Event" }.count == 1)
        #expect(server.records.filter { $0.recordType == "Event" }.count == 1)
        #expect(cloud.records.filter { $0.recordType == Int.recordType }.count == 1)
        #expect(server.records.filter { $0.recordType == Int.recordType }.count == 0)
    }

    @Test("Metrics go raw to servers and as matrices to CloudKit")
    func metricsSplit() async throws {
        IntMetricsObject.stub(name: "requests", telemetry: "counter", value: 5, in: context)
        try context.save()

        let engine = SyncEngine(backends: backends, context: context)
        try await engine.send(type: IntMetricsObject.self)

        #expect(server.records.filter { $0.recordType == "IntMetric" }.count == 1)
        #expect(cloud.records.filter { $0.recordType == "IntMetric" }.count == 0)
        #expect(cloud.records.filter { $0.recordType == Int.recordType }.count == 1)
        #expect(server.records.filter { $0.recordType == Int.recordType }.count == 0)
    }

    @Test("A server-only setup skips the matrix stage entirely")
    func serverOnly() async throws {
        let event = EventObject.stub(name: "login", in: context)
        try context.save()

        let engine = SyncEngine(backends: [serverBackend], context: context)
        try await engine.send(type: EventObject.self)

        #expect(event.syncState == .synced)
        #expect(server.records.filter { $0.recordType == "Event" }.count == 1)
        #expect(server.records.filter { $0.recordType == Int.recordType }.isEmpty)
    }

    @Test("A failing backend leaves the batch unsynced without blocking the others")
    func failureIsolatedToBackend() async throws {
        let event = EventObject.stub(name: "login", in: context)
        try context.save()

        server.writeErrors.append(CKError(.networkFailure))

        let engine = SyncEngine(backends: backends, context: context)

        await #expect(throws: (any Error).self) {
            try await engine.send(type: EventObject.self)
        }

        // CloudKit got its raw record and matrix; the server got nothing.
        #expect(event.syncState != .synced)
        #expect(event.deliveredRaw.contains("cloud"))
        #expect(!event.deliveredRaw.contains("server"))
        #expect(cloud.records.filter { $0.recordType == "Event" }.count == 1)
        #expect(server.records.filter { $0.recordType == "Event" }.count == 0)
    }

    @Test("The recovered backend is retried alone; healthy ones aren't rewritten")
    func resumesWithoutRewritingHealthyBackends() async throws {
        let event = EventObject.stub(name: "login", in: context)
        try context.save()

        // First cycle: the server is down.
        server.writeErrors.append(CKError(.networkFailure))
        let engine = SyncEngine(backends: backends, context: context)
        await #expect(throws: (any Error).self) {
            try await engine.send(type: EventObject.self)
        }

        // Second cycle: the server has recovered.
        try await engine.send(type: EventObject.self)

        #expect(event.syncState == .synced)
        #expect(server.records.filter { $0.recordType == "Event" }.count == 1)
        // CloudKit's raw record and matrix were each written exactly once.
        #expect(cloud.records.filter { $0.recordType == "Event" }.count == 1)
        #expect(cloud.records.filter { $0.recordType == Int.recordType }.count == 1)
    }

    @Test("Dropping a never-reached backend lets the record sync")
    func droppingBackendUnblocks() async throws {
        let event = EventObject.stub(name: "login", in: context)
        try context.save()

        // The server never accepts the record.
        server.writeErrors.append(CKError(.networkFailure))
        let withServer = SyncEngine(backends: backends, context: context)
        await #expect(throws: (any Error).self) {
            try await withServer.send(type: EventObject.self)
        }
        #expect(event.syncState != .synced)

        // Reconfigured to CloudKit only — which already has the record.
        let cloudOnly = SyncEngine(backends: [cloudBackend], context: context)
        try await cloudOnly.send(type: EventObject.self)

        #expect(event.syncState == .synced)
    }
}
