//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import CoreData
import Testing

@testable import Scout
@testable import Support

@MainActor
@Suite("VisitEntry+Monitor")
struct VisitEntryMonitorTests {
    let context = NSManagedObjectContext.inMemoryContext()

    private func makeLaunch() -> LaunchEntry {
        LaunchEntry.stub(date: Date(year: 2026, month: 1, day: 1), in: context)
    }

    @Test("Trigger records one visit per day")
    func triggerIsIdempotent() throws {
        let launch = makeLaunch()

        try VisitEntry.Trigger(launchID: launch.launchID, date: Date(year: 2026, month: 1, day: 1, hour: 9))
            .execute(in: context)
        try VisitEntry.Trigger(launchID: launch.launchID, date: Date(year: 2026, month: 1, day: 1, hour: 17))
            .execute(in: context)

        let visits = try context.fetchAll(VisitEntry.self)
        #expect(visits.count == 1)
        #expect(visits.first?.launch == launch)
        #expect(visits.first?.day == Date(year: 2026, month: 1, day: 1))
    }

    @Test("A new day gets its own visit")
    func triggerNextDay() throws {
        let launch = makeLaunch()

        try VisitEntry.Trigger(launchID: launch.launchID, date: Date(year: 2026, month: 1, day: 1))
            .execute(in: context)
        try VisitEntry.Trigger(launchID: launch.launchID, date: Date(year: 2026, month: 1, day: 2))
            .execute(in: context)

        #expect(try context.fetchAll(VisitEntry.self).count == 2)
    }
}
