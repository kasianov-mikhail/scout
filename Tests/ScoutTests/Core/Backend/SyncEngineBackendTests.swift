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

    var backends: [ResolvedBackend] {
        [
            ResolvedBackend(
                database: cloud,
                needsClientAggregation: true,
                acceptsRawMetrics: false,
                checkAvailability: {}
            ),
            ResolvedBackend(
                database: server,
                needsClientAggregation: false,
                acceptsRawMetrics: true,
                checkAvailability: {}
            ),
        ]
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

        let engine = SyncEngine(
            backends: [
                ResolvedBackend(
                    database: server,
                    needsClientAggregation: false,
                    acceptsRawMetrics: true,
                    checkAvailability: {}
                )
            ],
            context: context
        )
        try await engine.send(type: EventObject.self)

        #expect(event.syncState == .synced)
        #expect(server.records.filter { $0.recordType == "Event" }.count == 1)
        #expect(server.records.filter { $0.recordType == Int.recordType }.isEmpty)
    }

    @Test("A failing backend keeps the batch pending for every backend")
    func failureKeepsBatchPending() async throws {
        let event = EventObject.stub(name: "login", in: context)
        try context.save()

        server.writeErrors.append(CKError(.networkFailure))

        let engine = SyncEngine(backends: backends, context: context)

        await #expect(throws: (any Error).self) {
            try await engine.send(type: EventObject.self)
        }

        #expect(event.syncState == .pending)
    }
}
