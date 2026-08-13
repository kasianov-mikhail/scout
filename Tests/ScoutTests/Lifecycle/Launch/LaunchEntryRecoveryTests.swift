//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Testing

@testable import Scout
@testable import Support

@MainActor
@Suite("LaunchEntry+Recovery")
struct LaunchEntryRecoveryTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let identity = Identity.stub
    let date = TestDate.reference

    @Test("Closes launches from previous launches")
    func closesStale() throws {
        let launch = LaunchEntry.stub(date: date, in: context)
        launch.launchID = UUID()

        try context.save()
        try LaunchEntry.Recovery(launchID: identity.launch).execute(in: context)

        #expect(launch.endDate == date)
    }

    @Test("Queues a closed launch for delivery again")
    func requeuesClosed() throws {
        let launch = LaunchEntry.stub(date: date, in: context)
        launch.launchID = UUID()

        let delivery = launch.seedDelivery(pending: false, attempts: 3, for: "cloud", in: context)

        try context.save()
        try LaunchEntry.Recovery(launchID: identity.launch).execute(in: context)

        #expect(delivery.isPending)
        #expect(delivery.attempts == 0)
    }

    @Test("Does not close launches from current launch")
    func skipsCurrent() throws {
        let launch = LaunchEntry.stub(date: date, in: context)

        try context.save()
        try LaunchEntry.Recovery(launchID: identity.launch).execute(in: context)

        #expect(launch.endDate == nil)
    }

    @Test("Does not modify already completed launches")
    func skipsCompleted() throws {
        let endDate = date.addingTimeInterval(300)
        let launch = LaunchEntry.stub(date: date, endDate: endDate, in: context)
        launch.launchID = UUID()

        try context.save()
        try LaunchEntry.Recovery(launchID: identity.launch).execute(in: context)

        #expect(launch.endDate == endDate)
    }

    @Test("Uses latest child timestamp as endDate")
    func endDateFromChild() throws {
        let launch = LaunchEntry.stub(date: date, in: context)
        launch.launchID = UUID()

        let early = SessionEntry.stub(date: date.addingTimeInterval(10), launch: launch, in: context)
        early.sessionID = UUID()

        let latest = date.addingTimeInterval(300)
        SessionEntry.stub(date: latest, launch: launch, in: context)

        try context.save()
        try LaunchEntry.Recovery(launchID: identity.launch).execute(in: context)

        #expect(launch.endDate == latest)
    }
}
