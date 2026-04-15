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
@Suite("completeStaleSessions")
struct CompletStaleSessionsTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let date = Date(timeIntervalSince1970: 1_724_457_600)

    @Test("Closes sessions from previous launches")
    func closesStaleSession() throws {
        let session = SessionObject.stub(date: date, in: context)
        session.launchID = UUID()

        try context.save()
        try completeStaleSessions(in: context)

        #expect(session.endDate == date)
    }

    @Test("Closes launches from previous launches")
    func closestaleLaunch() throws {
        let launch = LaunchObject.stub(date: date, in: context)
        launch.launchID = UUID()

        try context.save()
        try completeStaleSessions(in: context)

        #expect(launch.endDate == date)
    }

    @Test("Does not close sessions from current launch")
    func skipsCurrentSession() throws {
        let session = SessionObject.stub(date: date, in: context)

        try context.save()
        try completeStaleSessions(in: context)

        #expect(session.endDate == nil)
    }

    @Test("Does not close launches from current launch")
    func skipsCurrentLaunch() throws {
        let launch = LaunchObject.stub(date: date, in: context)

        try context.save()
        try completeStaleSessions(in: context)

        #expect(launch.endDate == nil)
    }

    @Test("Does not modify already completed sessions")
    func skipsCompletedSession() throws {
        let endDate = date.addingTimeInterval(60)
        let session = SessionObject.stub(date: date, endDate: endDate, in: context)
        session.launchID = UUID()

        try context.save()
        try completeStaleSessions(in: context)

        #expect(session.endDate == endDate)
    }

    @Test("Does not modify already completed launches")
    func skipsCompletedLaunch() throws {
        let endDate = date.addingTimeInterval(300)
        let launch = LaunchObject.stub(date: date, endDate: endDate, in: context)
        launch.launchID = UUID()

        try context.save()
        try completeStaleSessions(in: context)

        #expect(launch.endDate == endDate)
    }
}
