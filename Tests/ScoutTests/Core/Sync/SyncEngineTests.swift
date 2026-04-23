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
}
