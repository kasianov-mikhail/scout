//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import ScoutUI
@testable import Support

struct RetentionDayTests {
    private let week = Date(year: 2026, month: 10, day: 13)
    private let now = Date(year: 2026, month: 11, day: 1)

    @Test("The tabs are day 1, 7 and 30")
    func tabs() {
        #expect(RetentionDay.tabs.map(\.rawValue) == [1, 7, 30])
    }

    @Test("A day waits for the whole cohort week and its offset")
    func availability() {
        #expect(RetentionDay.day7.pendingDays(week: week, now: now) == nil)
        #expect(RetentionDay.day14.pendingDays(week: week, now: now) == 2)
        #expect(RetentionDay.day30.pendingDays(week: week, now: now) == 18)
    }

    @Test("A pending day reads as days left")
    func label() {
        #expect(RetentionDay.day7.pendingLabel(week: week, now: now) == nil)
        #expect(RetentionDay.day14.pendingLabel(week: week, now: now) == "in 2 d")
        #expect(RetentionDay.day30.pendingLabel(week: week, now: now) == "in 18 d")
    }

    @Test("The day of availability leaves no whole day left")
    func lastDay() {
        let tomorrow = Date(year: 2026, month: 11, day: 2, hour: 12)

        #expect(RetentionDay.day14.pendingDays(week: week, now: tomorrow) == 1)
    }
}
