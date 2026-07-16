//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct CalendarMonthTests {
    let month = CalendarMonth(containing: Calendar.utc.date(from: DateComponents(year: 2026, month: 7, day: 15))!)

    @Test("Grid is six weeks of seven days") func layout() {
        #expect(month.weeks.count == 6)
        #expect(month.weeks.allSatisfy { $0.count == 7 })
        #expect(month.weeks.flatMap { $0 }.count == 42)
    }

    @Test("Monday-first leading spillover") func leading() {
        let first = month.weeks[0]

        #expect(first[0].number == 29)
        #expect(first[0].isCurrentMonth == false)
        #expect(first[2].number == 1)
        #expect(first[2].isCurrentMonth)
    }

    @Test("Trailing spillover into the next month") func trailing() {
        let last = month.weeks[5][6]

        #expect(last.number == 9)
        #expect(last.isCurrentMonth == false)
    }

    @Test("Days belonging to the month") func daysInMonth() {
        let inMonth = month.weeks.flatMap { $0 }.filter(\.isCurrentMonth)

        #expect(inMonth.count == 31)
    }

    @Test("Titles render in source English") func titles() {
        #expect(month.title == "July 2026")
        #expect(month.shortTitle == "JUL 2026")
    }
}
