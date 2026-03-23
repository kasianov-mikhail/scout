//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct DateAddComponentTests {
    let base = Date(timeIntervalSinceReferenceDate: 0)  // 2001-01-01 00:00:00 UTC

    // MARK: - Adding (non-mutating)

    @Test("addingDay adds one day by default")
    func addingDayDefault() {
        let result = base.addingDay()
        #expect(result.timeIntervalSince(base) == 86400)
    }

    @Test("addingDay adds multiple days")
    func addingDayMultiple() {
        let result = base.addingDay(5)
        #expect(result.timeIntervalSince(base) == 86400 * 5)
    }

    @Test("addingHour adds one hour by default")
    func addingHourDefault() {
        let result = base.addingHour()
        #expect(result.timeIntervalSince(base) == 3600)
    }

    @Test("addingHour adds multiple hours")
    func addingHourMultiple() {
        let result = base.addingHour(3)
        #expect(result.timeIntervalSince(base) == 3600 * 3)
    }

    @Test("addingWeek adds one week by default")
    func addingWeekDefault() {
        let result = base.addingWeek()
        #expect(result.timeIntervalSince(base) == 86400 * 7)
    }

    @Test("addingWeek adds multiple weeks")
    func addingWeekMultiple() {
        let result = base.addingWeek(2)
        #expect(result.timeIntervalSince(base) == 86400 * 14)
    }

    @Test("addingMonth adds one month by default")
    func addingMonthDefault() {
        let result = base.addingMonth()
        let components = Calendar.utc.dateComponents([.month], from: base, to: result)
        #expect(components.month == 1)
    }

    @Test("addingYear adds one year by default")
    func addingYearDefault() {
        let result = base.addingYear()
        let components = Calendar.utc.dateComponents([.year], from: base, to: result)
        #expect(components.year == 1)
    }

    @Test("adding with negative value subtracts")
    func addingNegative() {
        let result = base.addingDay(-1)
        #expect(result.timeIntervalSince(base) == -86400)
    }

    @Test("adding generic component works")
    func addingGeneric() {
        let result = base.adding(.minute, value: 30)
        #expect(result.timeIntervalSince(base) == 1800)
    }

    // MARK: - Mutating

    @Test("addDay mutates in place")
    func addDayMutating() {
        var date = base
        date.addDay()
        #expect(date.timeIntervalSince(base) == 86400)
    }

    @Test("addHour mutates in place")
    func addHourMutating() {
        var date = base
        date.addHour(2)
        #expect(date.timeIntervalSince(base) == 7200)
    }

    @Test("addWeek mutates in place")
    func addWeekMutating() {
        var date = base
        date.addWeek()
        #expect(date.timeIntervalSince(base) == 86400 * 7)
    }

    @Test("addMonth mutates in place")
    func addMonthMutating() {
        var date = base
        date.addMonth()
        let components = Calendar.utc.dateComponents([.month], from: base, to: date)
        #expect(components.month == 1)
    }

    @Test("addYear mutates in place")
    func addYearMutating() {
        var date = base
        date.addYear()
        let components = Calendar.utc.dateComponents([.year], from: base, to: date)
        #expect(components.year == 1)
    }
}
