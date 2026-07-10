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
@Suite("SessionObject+Recovery")
struct SessionObjectRecoveryTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let date = TestDate.reference

    private func staleLaunch() -> LaunchObject {
        let launch = LaunchObject.stub(date: date, in: context)
        launch.launchID = UUID()
        return launch
    }

    @Test("Closes sessions from previous launches")
    func closesStale() throws {
        let session = SessionObject.stub(date: date, launch: staleLaunch(), in: context)

        try context.save()
        try SessionObject.completeStale(in: context)

        #expect(session.endDate == date)
    }

    @Test("Does not close sessions from current launch")
    func skipsCurrent() throws {
        let launch = LaunchObject.stub(date: date, in: context)
        let session = SessionObject.stub(date: date, launch: launch, in: context)

        try context.save()
        try SessionObject.completeStale(in: context)

        #expect(session.endDate == nil)
    }

    @Test("Does not modify already completed sessions")
    func skipsCompleted() throws {
        let endDate = date.addingTimeInterval(60)
        let session = SessionObject.stub(date: date, endDate: endDate, launch: staleLaunch(), in: context)

        try context.save()
        try SessionObject.completeStale(in: context)

        #expect(session.endDate == endDate)
    }

    @Test("Uses latest child event date as endDate")
    func endDateFromChildEvent() throws {
        let session = SessionObject.stub(date: date, launch: staleLaunch(), in: context)

        let latest = date.addingTimeInterval(120)
        EventObject.stub(name: "x", date: latest, session: session, in: context)

        try context.save()
        try SessionObject.completeStale(in: context)

        #expect(session.endDate == latest)
    }
}
