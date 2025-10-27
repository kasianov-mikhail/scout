//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct ChartModelTests {
    let date: Date
    let range: Range<Date>
    let points: [ChartPoint<Int>]

    init() {
        date = Date()
        range = date..<date.addingTimeInterval(3600)

        let chartPoint1 = ChartPoint(date: date, count: 10)
        let chartPoint2 = ChartPoint(date: date.addingTimeInterval(86400), count: 20)

        points = [chartPoint1, chartPoint2]
    }

    @Test("Points from data") func testPointsFromData() throws {
        let extent = ChartExtent(period: Period.today, domain: range)
        let points = extent.segment(from: points)

        #expect(points.map(\.count) == [10])
    }
}
