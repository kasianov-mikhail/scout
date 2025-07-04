//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct RawPointDataTests {
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()

    @Test("Grouping by day") func testChartDataByDay() {
        let from = formatter.date(from: "2024-01-01 00:00:00")!
        let to = formatter.date(from: "2024-01-03 00:00:00")!
        let points = [
            ChartPoint(date: formatter.date(from: "2024-01-01 12:00:00")!, count: 5),
            ChartPoint(date: formatter.date(from: "2024-01-02 12:00:00")!, count: 10)
        ]
        let rawData = RawPointData(from: from, to: to, points: points)

        let grouped = rawData.group(by: .day)

        #expect(grouped.map(\.count) == [5, 10])
    }

    @Test("Grouping by hour") func testChartDataByHour() {
        let from = formatter.date(from: "2024-01-01 00:00:00")!
        let to = formatter.date(from: "2024-01-01 03:00:00")!
        let points = [
            ChartPoint(date: formatter.date(from: "2024-01-01 01:00:00")!, count: 5),
            ChartPoint(date: formatter.date(from: "2024-01-01 02:00:00")!, count: 10)
        ]
        let rawData = RawPointData(from: from, to: to, points: points)

        let grouped = rawData.group(by: .hour)

        #expect(grouped.map(\.count) == [0, 5, 10])
    }

    @Test("Grouping no points") func testChartDataNoPoints() {
        let from = formatter.date(from: "2024-01-01 00:00:00")!
        let to = formatter.date(from: "2024-01-01 03:00:00")!
        let points: [ChartPoint] = []
        let series = RawPointData(from: from, to: to, points: points)

        let grouped = series.group(by: .hour)

        #expect(grouped.map(\.count) == [0, 0, 0])
    }
}
