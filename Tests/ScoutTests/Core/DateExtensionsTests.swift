//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct DateExtensionsTests {
    let date: Date
    let set: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]

    init() {
        let components = DateComponents(
            year: 2030,
            month: 3,
            day: 5,
            hour: 7,
            minute: 9,
            second: 11
        )
        date = Calendar.UTC.date(from: components)!
    }

    @Test("Start of an hour") func startOfHour() {
        let hour = date.startOfHour
        let components = Calendar.UTC.dateComponents(set, from: hour)

        #expect(components.year == 2030)
        #expect(components.month == 3)
        #expect(components.day == 5)
        #expect(components.hour == 7)
        #expect(components.minute == 0)
        #expect(components.second == 0)
    }

    @Test("Start of a week") func startOfWeek() {
        let week = date.startOfWeek
        let components = Calendar.UTC.dateComponents(set, from: week)

        #expect(components.year == 2030)
        #expect(components.month == 3)
        #expect(components.day == 3)
        #expect(components.hour == 0)
        #expect(components.minute == 0)
        #expect(components.second == 0)
    }
}
