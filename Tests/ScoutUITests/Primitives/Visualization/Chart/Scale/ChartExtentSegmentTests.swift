//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import Foundation
import Testing

@testable import ScoutUI
@testable import Support

struct ChartExtentSegmentTests {
    let date: Date
    let range: Range<Date>
    let points: [ChartPoint<Int>]

    init() {
        date = Date()
        range = date..<date.addingTimeInterval(3600)

        let chartPoint1 = ChartPoint(date: date, value: 10)
        let chartPoint2 = ChartPoint(date: date.addingTimeInterval(86400), value: 20)

        points = [chartPoint1, chartPoint2]
    }

    @Test("Points from data") func testPointsFromData() throws {
        let extent = ChartExtent(period: Period.today, domain: range)
        let points = extent.segment(from: points)

        #expect(points.map(\.value) == [10])
    }

    @Test("A peak fold keeps the largest hourly value of each day, not the sum")
    func peakFold() {
        let day = Date(year: 2026, month: 6, day: 10)
        let points = [3, 9, 4].enumerated().map { hour, value in
            ChartPoint(date: day.addingTimeInterval(Double(hour) * 3600), value: value)
        }

        let total = ChartExtent(period: Period.week, domain: day..<day.addingTimeInterval(86400))
        let peak = ChartExtent(period: Period.week, domain: day..<day.addingTimeInterval(86400), fold: .peak)

        #expect(total.segment(from: points).map(\.value) == [16])
        #expect(peak.segment(from: points).map(\.value) == [9])
    }
}
