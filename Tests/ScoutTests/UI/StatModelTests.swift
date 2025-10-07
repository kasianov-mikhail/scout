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
    let chartData: ChartData<Period>

    init() {
        date = Date()
        range = date..<date.addingTimeInterval(3600)

        let chartPoint1 = ChartPoint(date: date, count: 10)
        let chartPoint2 = ChartPoint(date: date.addingTimeInterval(86400), count: 20)

        chartData = [.today: [chartPoint1, chartPoint2]]
    }

    @Test("Points from data") func testPointsFromData() throws {
        let chartModel = ChartModel(period: Period.today, range: range)
        let points = try #require(chartModel.points(from: chartData))

        #expect(points.map(\.count) == [10])
    }

    @Test("Points from nil data") func testPointsFromNilData() {
        let chartModel = ChartModel(period: Period.week, range: range)
        let points = chartModel.points(from: nil)

        #expect(points == nil)
    }

    @Test("Points from data with different period") func testPointsFromDataWithDifferentPeriod() {
        let chartModel = ChartModel(period: Period.yesterday, range: range)
        let points = chartModel.points(from: chartData)

        #expect(points == nil)
    }
}
