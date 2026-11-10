//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import ScoutUI
@testable import Support

struct RangeLabelTests {
    let formatter = DateFormatter(format: "yyyy-MM-dd")
    let now = Date(year: 2026, month: 11, day: 10)

    @Test("Single day range") func testSingleDayRange() throws {
        let startDate = try #require(formatter.date(from: "2024-01-01"))
        let endDate = try #require(formatter.date(from: "2024-01-02"))
        let range = startDate..<endDate
        let label = range.label(using: formatter)

        #expect(label == "2024-01-01")
    }

    @Test("Multiple days range") func testMultipleDaysRange() throws {
        let startDate = try #require(formatter.date(from: "2024-01-01"))
        let endDate = try #require(formatter.date(from: "2024-01-04"))
        let range = startDate..<endDate
        let label = range.label(using: formatter)

        #expect(label == "2024-01-01 – 2024-01-03")
    }

    @Test("A range that ends in the future is labeled up to today") func testFutureRangeEndsToday() {
        let range = Date(year: 2025, month: 12, day: 1)..<Date(year: 2026, month: 12, day: 1)
        let label = range.label(using: formatter, now: now)

        #expect(label == "2025-12-01 – 2026-11-10")
    }

    @Test("A range that ends today keeps its label") func testTodaysRange() {
        let range = Date(year: 2026, month: 11, day: 10)..<Date(year: 2026, month: 11, day: 11)
        let label = range.label(using: formatter, now: now)

        #expect(label == "2026-11-10")
    }

    @Test("A past range keeps its label") func testPastRange() {
        let range = Date(year: 2026, month: 10, day: 11)..<Date(year: 2026, month: 11, day: 10)
        let label = range.label(using: formatter, now: now)

        #expect(label == "2026-10-11 – 2026-11-09")
    }
}
