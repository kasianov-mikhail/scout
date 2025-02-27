//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Testing

@testable import Scout

struct SessionObjectTests {
    let context = NSManagedObjectContext.inMemoryContext()

    @Test("Session trigger") func testTrigger() throws {
        try SessionObject.trigger(in: context)

        let fetchRequest: NSFetchRequest<SessionObject> = SessionObject.fetchRequest()
        let sessions = try context.fetch(fetchRequest)

        #expect(sessions.count == 1)

        let session = sessions[0]
        #expect(session.date != nil)
        #expect(session.endDate == nil)
    }

    @Test("Session complete") func testComplete() throws {
        // First, trigger a session
        try SessionObject.trigger(in: context)

        // Then, complete the session
        try SessionObject.complete(in: context)

        let fetchRequest: NSFetchRequest<SessionObject> = SessionObject.fetchRequest()
        let sessions = try context.fetch(fetchRequest)

        #expect(sessions.count == 1)

        let session = sessions[0]
        #expect(session.endDate != nil)
    }

    @Test("Complete the most recent session") func testCompleteMostRecent() throws {
        // First, trigger a session
        try SessionObject.trigger(in: context)

        // Then, trigger another session
        try SessionObject.trigger(in: context)

        // Then, complete the most recent session
        try SessionObject.complete(in: context)

        let fetchRequest: NSFetchRequest<SessionObject> = SessionObject.fetchRequest()
        let sessions = try context.fetch(fetchRequest)

        #expect(sessions.count == 2)
        #expect(sessions[0].endDate == nil)
        #expect(sessions[1].endDate != nil)
    }

    @Test("Complete with no active session") func testCompleteNoActiveSession() throws {
        #expect(throws: SessionObject.CompleteError.sessionNotFound) {
            try SessionObject.complete(in: context)
        }
    }

    @Test("Complete an already completed session") func testCompleteAlreadyCompleted() throws {
        // First, trigger a session
        try SessionObject.trigger(in: context)

        // Then, complete the session
        try SessionObject.complete(in: context)

        #expect(throws: SessionObject.CompleteError.alreadyCompleted(Date())) {
            try SessionObject.complete(in: context)
        }
    }
}
