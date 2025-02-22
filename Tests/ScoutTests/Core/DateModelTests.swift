//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct DateModelTests {
    class TestModel: DateModel {
        var datePrimitive: Date?
        var hour: Date?
        var day: Date?
        var week: Date?
        var month: Date?
    }

    let components = DateComponents(year: 2025, month: 3, day: 5, hour: 7, minute: 9, second: 11)
    let componentSet: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]

    @Test("Set date") func testSetDate() throws {
        let date = Calendar.UTC.date(from: components)!
        let model = TestModel()
        model.date = date

        let hourDate = try #require(model.hour)
        let hour = Calendar.UTC.dateComponents(componentSet, from: hourDate)
        #expect(hour.year == 2025)
        #expect(hour.month == 3)
        #expect(hour.day == 5)
        #expect(hour.hour == 7)
        #expect(hour.minute == 0)
        #expect(hour.second == 0)

        let dayDate = try #require(model.day)
        let day = Calendar.UTC.dateComponents(componentSet, from: dayDate)
        #expect(day.year == 2025)
        #expect(day.month == 3)
        #expect(day.day == 5)
        #expect(day.hour == 0)
        #expect(day.minute == 0)
        #expect(day.second == 0)

        let weekDate = try #require(model.week)
        let week = Calendar.UTC.dateComponents(componentSet, from: weekDate)
        #expect(week.year == 2025)
        #expect(week.month == 3)
        #expect(week.day == 2)
        #expect(week.hour == 0)
        #expect(week.minute == 0)
        #expect(week.second == 0)

        let monthDate = try #require(model.month)
        let month = Calendar.UTC.dateComponents(componentSet, from: monthDate)
        #expect(month.year == 2025)
        #expect(month.month == 3)
        #expect(month.day == 1)
        #expect(month.hour == 0)
        #expect(month.minute == 0)
        #expect(month.second == 0)
    }
}
