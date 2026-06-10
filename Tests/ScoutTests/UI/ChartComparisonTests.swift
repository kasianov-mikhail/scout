//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct ChartComparisonTests {
    let date = Date()

    @Test("Previous domain") func testPreviousDomain() {
        let interval: Double = 3600 * 24 * 7
        let range = date..<date.addingTimeInterval(interval)
        let model = ChartExtent(period: Period.week, domain: range)

        let expectedRange = date.addingTimeInterval(-interval)..<date
        #expect(model.previousDomain == expectedRange)
    }

    @Test("Previous extent") func testPreviousExtent() {
        let model = ChartExtent(period: Period.week)
        let previous = model.previousExtent

        #expect(previous.period == .week)
        #expect(previous.domain == model.previousDomain)
    }

    @Test("Previous segment") func testPreviousSegment() {
        let upper = Date().startOfDay
        let model = ChartExtent(period: Period.week, domain: upper.addingWeek(-1)..<upper)

        let points = [
            ChartPoint(date: upper.addingDay(-1), count: 3),
            ChartPoint(date: upper.addingDay(-8), count: 5),
        ]

        #expect(model.segment(from: points).total == 3)
        #expect(model.previousSegment(from: points).total == 5)
    }

    @Test("Overlay segment alignment") func testOverlaySegment() {
        let upper = Date().startOfDay
        let model = ChartExtent(period: Period.week, domain: upper.addingWeek(-1)..<upper)

        let points = [
            ChartPoint(date: upper.addingDay(-1), count: 3),
            ChartPoint(date: upper.addingDay(-8), count: 5),
        ]
        let overlay = model.overlaySegment(from: points)

        #expect(overlay.map(\.date) == model.segment(from: points).map(\.date))
        #expect(overlay.first == ChartPoint(date: upper.addingDay(-1), count: 5))
        #expect(overlay.total == 5)
    }

    @Test("Overlay segment truncation") func testOverlayTruncation() {
        // 2026-03-15 UTC: the current month window spans 28 days, the previous one 31.
        let upper = Date(timeIntervalSince1970: 1_773_532_800)
        let model = ChartExtent(period: Period.month, domain: upper.addingMonth(-1)..<upper)

        let points: [ChartPoint<Int>] = []

        #expect(model.segment(from: points).count == 28)
        #expect(model.overlaySegment(from: points).count == 28)
    }
}
