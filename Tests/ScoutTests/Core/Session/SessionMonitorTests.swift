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
struct SessionMonitorTests {
    let context = NSManagedObjectContext.inMemoryContext()

    @Test("trigger creates a new session")
    func testTrigger() throws {
        try SessionObject.trigger(in: context)

        let request = NSFetchRequest<SessionObject>(entityName: "SessionObject")
        let sessions = try context.fetch(request)

        #expect(sessions.count == 1)
        #expect(sessions[0].date != nil)
        #expect(sessions[0].endDate == nil)
    }

    @Test("complete sets endDate on current session")
    func testComplete() throws {
        try SessionObject.trigger(in: context)
        try SessionObject.complete(in: context)

        let request = NSFetchRequest<SessionObject>(entityName: "SessionObject")
        let sessions = try context.fetch(request)

        #expect(sessions.count == 1)
        #expect(sessions[0].endDate != nil)
    }

    @Test("complete throws notFound when no session exists")
    func testCompleteNotFound() throws {
        #expect(throws: MonitorError.self) {
            try SessionObject.complete(in: context)
        }
    }

    @Test("complete throws alreadyCompleted for finished session")
    func testCompleteAlreadyCompleted() throws {
        try SessionObject.trigger(in: context)
        try SessionObject.complete(in: context)

        #expect(throws: MonitorError.self) {
            try SessionObject.complete(in: context)
        }
    }
}
