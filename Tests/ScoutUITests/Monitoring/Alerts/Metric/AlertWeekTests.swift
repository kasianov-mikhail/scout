//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import Testing

@testable import ScoutUI

struct AlertWeekTests {
    @Test("The week has seven days ending yesterday")
    func days() {
        let week = AlertWeek.crashFreeSample

        #expect(week.days.count == 7)
        #expect(week.days.last?.date == week.end.addingDay(-1))
        #expect(week.days.allSatisfy { $0.values.count == 24 })
    }

    @Test("A crash-free week counts alerts by sensitivity")
    func crashFreeCounts() {
        let counts = AlertWeek.crashFreeSample.fireCounts(for: AlertDraft(watch: .crashFreeDrop))

        #expect(counts[.low] == 1)
        #expect(counts[.normal] == 2)
        #expect(counts[.high] == 4)
    }

    @Test("An event week counts alerts by factor")
    func eventCounts() {
        let draft = AlertDraft(watch: .eventSpike, eventName: "PaymentDeclined")
        let counts = AlertWeek.sample.fireCounts(for: draft)

        #expect(counts[.low] == 0)
        #expect(counts[.normal] == 2)
        #expect(counts[.high] == 7)
    }

    @Test("The grid marks the breached hours")
    func breaches() {
        let draft = AlertDraft(watch: .crashFreeDrop)
        let grid = AlertWeek.crashFreeSample.breachGrid(for: draft.rule)

        #expect(grid.count == 7)
        #expect(grid.flatMap { $0 }.count == 168)
        #expect(grid.flatMap { $0 }.count(where: { $0 }) == 7)
    }

    @Test("The placeholder days end yesterday")
    func weekDays() {
        let end = Date(timeIntervalSince1970: 1_800_000_000).startOfDay
        let days = AlertWeek.weekDays(ending: end)

        #expect(days.count == 7)
        #expect(days.first == end.addingDay(-7))
        #expect(days.last == end.addingDay(-1))
    }

    @Test("The usual range spans the common hourly counts")
    func usualRange() {
        #expect(AlertWeek.sample.usualRange == 8...14)
    }
}
