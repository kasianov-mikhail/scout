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

    @Test("Uploads the matrix once and marks the batch synced")
    func marksBatchSynced() async throws {
        let event = EventObject.stub(name: "x", in: context)
        try context.save()

        let engine = SyncEngine(database: database, context: context)
        try await engine.send(type: EventObject.self)

        #expect(event.syncState == .synced)
        #expect(database.records.filter { $0.recordType == Int.recordType }.count == 1)
    }

    @Test("Does not re-upload or re-contribute progress already recorded for a backend")
    func skipsDeliveredStepsOnRetry() async throws {
        // Simulate a crash after the raw upload and matrix contribution were
        // persisted but before the final save: progress is recorded yet the
        // record is still unsynced.
        let event = EventObject.stub(name: "x", in: context)
        event.mark([.raw, .matrix], for: "default")
        try context.save()

        let engine = SyncEngine(database: database, context: context)
        try await engine.send(type: EventObject.self)

        #expect(event.syncState == .synced)
        #expect(database.events.isEmpty)
        #expect(database.records.filter { $0.recordType == Int.recordType }.isEmpty)
    }

    @Test("Migrates a legacy aggregated record without re-uploading or re-counting")
    func migratesLegacyAggregated() async throws {
        // A record left `.aggregated` by an older build already reached every
        // backend; the new pipeline must neither re-upload nor double-count it.
        let event = EventObject.stub(name: "x", in: context)
        event.syncState = .aggregated
        try context.save()

        let engine = SyncEngine(database: database, context: context)
        try await engine.send(type: EventObject.self)

        #expect(event.syncState == .synced)
        #expect(database.records.isEmpty)
    }
}
