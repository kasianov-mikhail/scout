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
@Suite("SyncEngine")
struct SyncEngineTests {
    let database = InMemoryDatabase()
    let context = NSManagedObjectContext.inMemoryContext()

    @Test("Persists syncAttempts when upload fails")
    func persistsSyncAttemptsOnFailure() async throws {
        let event = EventObject.stub(name: "x", in: context)
        event.eventID = UUID()
        try context.save()

        database.writeErrors.append(CKError(.networkFailure))

        let engine = SyncEngine(database: database, context: context)

        await #expect(throws: (any Error).self) {
            try await engine.send(type: EventObject.self)
        }

        #expect(event.syncAttempts == 1)
        #expect(!context.hasChanges)
    }

    @Test("Uploads the matrix once and marks the batch aggregated")
    func marksBatchAggregated() async throws {
        let event = EventObject.stub(name: "x", in: context)
        try context.save()

        let engine = SyncEngine(database: database, context: context)
        try await engine.send(type: EventObject.self)

        #expect(event.isAggregated)
        #expect(event.isSynced)
        #expect(database.records.filter { $0.recordType == Int.recordType }.count == 1)
    }

    @Test("Does not re-contribute an aggregated batch to the matrix on retry")
    func skipsMatrixUploadOnRetry() async throws {
        // Simulate a crash after the matrix upload was persisted but before
        // the final save: the record is aggregated yet still unsynced.
        let event = EventObject.stub(name: "x", in: context)
        event.isAggregated = true
        try context.save()

        let engine = SyncEngine(database: database, context: context)
        try await engine.send(type: EventObject.self)

        #expect(event.isSynced)
        #expect(database.events.count == 1)
        #expect(database.records.filter { $0.recordType == Int.recordType }.count == 0)
    }
}
