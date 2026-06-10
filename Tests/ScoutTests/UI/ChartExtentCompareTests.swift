//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Testing

@testable import Scout

struct ChartExtentCompareTests {
    let date = Date()

    @Test("Previous domain") func testPreviousDomain() {
        let interval: Double = 3600 * 24 * 7
        let range = date..<date.addingTimeInterval(interval)
        let model = ChartExtent(period: Period.week, domain: range)

        let expectedRange = date.addingTimeInterval(-interval)..<date
        #expect(model.previousDomain == expectedRange)
    }

    @Test("Comparison is nil when not comparing") func testComparisonOff() {
        let range = date..<date.addingTimeInterval(3600 * 24 * 7)
        let model = ChartExtent(period: Period.week, domain: range)

        let point = ChartPoint(date: date.addingTimeInterval(-3600), count: 5)
        #expect(model.comparison(from: [point]) == nil)
    }

    @Test("Comparison shifts previous period onto current domain") func testComparisonShift() {
        let interval: Double = 3600 * 24 * 7
        let range = date..<date.addingTimeInterval(interval)
        var model = ChartExtent(period: Period.week, domain: range)
        model.isComparing = true

        let point = ChartPoint(date: date.addingTimeInterval(-3600), count: 5)
        let comparison = model.comparison(from: [point])

        let expectedPoint = ChartPoint(
            date: date.addingTimeInterval(interval - 3600 * 24),
            count: 5
        )
        #expect(comparison?.first == expectedPoint)
        #expect(comparison?.count == 7)
        #expect(comparison?.total == 5)
    }

    @Test("Comparison points fall within current domain") func testComparisonAlignment() {
        let range = date..<date.addingTimeInterval(3600 * 24 * 7)
        var model = ChartExtent(period: Period.week, domain: range)
        model.isComparing = true

        let points = (0..<14).map { i in
            ChartPoint(date: date.addingTimeInterval(Double(-3600 * 24 * i)), count: 1)
        }
        let comparison = model.comparison(from: points)

        #expect(comparison?.allSatisfy { range.contains($0.date) } == true)
    }
}
