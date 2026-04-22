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
@Suite("SessionObject.completeStale")
struct CompleteStaleSessionTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let date = Date(timeIntervalSince1970: 1_724_457_600)

    @Test("Closes sessions from previous launches")
    func closesStale() throws {
        let session = SessionObject.stub(date: date, in: context)
        session.launchID = UUID()

        try context.save()
        try SessionObject.completeStale(in: context)

        #expect(session.endDate == date)
    }

    @Test("Does not close sessions from current launch")
    func skipsCurrent() throws {
        let session = SessionObject.stub(date: date, in: context)

        try context.save()
        try SessionObject.completeStale(in: context)

        #expect(session.endDate == nil)
    }

    @Test("Does not modify already completed sessions")
    func skipsCompleted() throws {
        let endDate = date.addingTimeInterval(60)
        let session = SessionObject.stub(date: date, endDate: endDate, in: context)
        session.launchID = UUID()

        try context.save()
        try SessionObject.completeStale(in: context)

        #expect(session.endDate == endDate)
    }
}

@MainActor
@Suite("LaunchObject.completeStale")
struct CompleteStaleLaunchTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let date = Date(timeIntervalSince1970: 1_724_457_600)

    @Test("Closes launches from previous launches")
    func closesStale() throws {
        let launch = LaunchObject.stub(date: date, in: context)
        launch.launchID = UUID()

        try context.save()
        try LaunchObject.completeStale(in: context)

        #expect(launch.endDate == date)
    }

    @Test("Does not close launches from current launch")
    func skipsCurrent() throws {
        let launch = LaunchObject.stub(date: date, in: context)

        try context.save()
        try LaunchObject.completeStale(in: context)

        #expect(launch.endDate == nil)
    }

    @Test("Does not modify already completed launches")
    func skipsCompleted() throws {
        let endDate = date.addingTimeInterval(300)
        let launch = LaunchObject.stub(date: date, endDate: endDate, in: context)
        launch.launchID = UUID()

        try context.save()
        try LaunchObject.completeStale(in: context)

        #expect(launch.endDate == endDate)
    }
}
