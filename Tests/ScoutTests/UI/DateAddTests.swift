//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct DateAddTests {
    let date = Date(timeIntervalSinceReferenceDate: 0)

    @Test("Adding hours") func testAddingHours() {
        let result = date.addingHour(3)
        #expect(result.timeIntervalSinceReferenceDate == 10_800)
    }

    @Test("Adding days") func testAddingDays() {
        let result = date.addingDay(3)
        #expect(result.timeIntervalSinceReferenceDate == 259_200)
    }

    @Test("Adding weeks") func testAddingWeeks() {
        let result = date.addingWeek(3)
        #expect(result.timeIntervalSinceReferenceDate == 1_814_400)
    }

    @Test("Adding months") func testAddingMonths() {
        let result = date.addingMonth(3)
        #expect(result.timeIntervalSinceReferenceDate == 7_776_000)
    }

    @Test("Adding years") func testAddingYears() {
        let result = date.addingYear(3)
        #expect(result.timeIntervalSinceReferenceDate == 94_608_000)
    }
}
