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

    @Test("Closes sessions from previous launches")
    func closesStale() throws {
        let session = SessionObject.stub(date: date, in: context)
        session.launch = LaunchObject.stub(date: date, in: context)

        try context.save()
        try SessionObject.completeStale(in: context)

        #expect(session.endDate == date)
    }

    @Test("Does not close sessions from current launch")
    func skipsCurrent() throws {
        let currentLaunch = LaunchObject.stub(date: date, in: context)
        try context.save()
        context.persistentStoreCoordinator?.hubObjectIDs.launch = currentLaunch.objectID

        let session = SessionObject.stub(date: date, in: context)
        session.launch = currentLaunch

        try context.save()
        try SessionObject.completeStale(in: context)

        #expect(session.endDate == nil)
    }

    @Test("Does not modify already completed sessions")
    func skipsCompleted() throws {
        let endDate = date.addingTimeInterval(60)
        let session = SessionObject.stub(date: date, endDate: endDate, in: context)
        session.launch = LaunchObject.stub(date: date, in: context)

        try context.save()
        try SessionObject.completeStale(in: context)

        #expect(session.endDate == endDate)
    }

    @Test("Uses latest child event date as endDate")
    func endDateFromChildEvent() throws {
        let session = SessionObject.stub(date: date, in: context)
        session.launch = LaunchObject.stub(date: date, in: context)

        let latest = date.addingTimeInterval(120)
        let event = EventObject.stub(name: "x", date: latest, in: context)
        event.session = session

        try context.save()
        try SessionObject.completeStale(in: context)

        #expect(session.endDate == latest)
    }
}
