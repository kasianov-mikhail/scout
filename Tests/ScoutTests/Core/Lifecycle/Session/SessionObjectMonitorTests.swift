//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Testing

@testable import Scout

@MainActor
@Suite("SessionObject+Monitor")
struct SessionObjectMonitorTests {
    let context = NSManagedObjectContext.inMemoryContext()

    @Test("complete sets endDate on an open session")
    func completeOpenSession() throws {
        try SessionObject.trigger(in: context)

        try SessionObject.complete(in: context)

        let sessions = try context.fetch(NSFetchRequest<SessionObject>(entityName: "SessionObject"))
        #expect(sessions.count == 1)
        #expect(sessions.first?.endDate != nil)
    }

    @Test("complete is a no-op when the session is already closed")
    func completeTwiceIsNoop() throws {
        try SessionObject.trigger(in: context)
        try SessionObject.complete(in: context)

        let firstEndDate = try #require(try context
            .fetch(NSFetchRequest<SessionObject>(entityName: "SessionObject"))
            .first?.endDate)

        try SessionObject.complete(in: context)

        let session = try #require(try context
            .fetch(NSFetchRequest<SessionObject>(entityName: "SessionObject"))
            .first)
        #expect(session.endDate == firstEndDate)
    }

    @Test("complete throws notFound when no session exists for the current launch")
    func completeWithoutSessionThrows() throws {
        #expect(throws: MonitorError.notFound) {
            try SessionObject.complete(in: context)
        }
    }
}
