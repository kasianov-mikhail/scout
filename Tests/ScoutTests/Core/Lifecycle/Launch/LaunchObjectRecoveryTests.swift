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
@Suite("LaunchObject+Recovery")
struct LaunchObjectRecoveryTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let date = TestDate.reference

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

    @Test("Uses latest child timestamp as endDate")
    func endDateFromChild() throws {
        let launch = LaunchObject.stub(date: date, in: context)
        launch.launchID = UUID()

        SessionObject.stub(date: date.addingTimeInterval(10), launch: launch, in: context)

        let latest = date.addingTimeInterval(300)
        SessionObject.stub(date: latest, launch: launch, in: context)

        try context.save()
        try LaunchObject.completeStale(in: context)

        #expect(launch.endDate == latest)
    }
}
