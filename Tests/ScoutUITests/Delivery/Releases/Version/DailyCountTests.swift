//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import Testing

@testable import ScoutUI

struct DailyCountTests {
    private let window = Date().trailingTwoWeeks
    private let today = Date().startOfDay

    @Test("The window covers fourteen UTC days ending today")
    func testWindow() {
        let days = [DailyCount](window: window)

        #expect(days.count == 14)
        #expect(days.last?.date == today)
        #expect(days.allSatisfy { $0.date == $0.date.startOfDay && $0.count == 0 })
    }

    @Test("Points of the version bucket into per-day counts across categories")
    func testDailyBuckets() {
        let series = [
            series(category: "cpu", points: [today.addingTimeInterval(3600): 2, today.addingDay(-1): 1]),
            series(category: "disk_write", points: [today: 3]),
        ]

        let days = series.dailyCounts(version: "2.0", window: window)

        #expect(days.count == 14)
        #expect(days.last?.count == 5)
        #expect(days[12].count == 1)
        #expect(days.dropLast(2).allSatisfy { $0.count == 0 })
    }

    @Test("Other versions, versionless series and points outside the window are ignored")
    func testFiltersVersionAndWindow() {
        let series = [
            series(version: "1.0", points: [today: 4]),
            series(version: nil, points: [today: 6]),
            series(points: [today.addingDay(-30): 7, today.addingDay(): 8]),
        ]

        let days = series.dailyCounts(version: "2.0", window: window)

        #expect(days.count == 14)
        #expect(days.allSatisfy { $0.count == 0 })
    }

    private func series(category: String? = nil, version: String? = "2.0", points: [Date: Int]) -> MetricSeries {
        MetricSeries(
            name: ResourceException.recordType,
            category: category,
            version: version,
            points: points.map { MetricSeriesPoint(date: $0.key, value: Double($0.value)) }
        )
    }
}
