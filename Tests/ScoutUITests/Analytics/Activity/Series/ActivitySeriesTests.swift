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
@testable import Support

struct ActivitySeriesTests {
    private let now = Date(year: 2026, month: 10, day: 25)

    @Test("The 30-day window includes today")
    func bounds() {
        let series = ActivitySeries(points: [], metric: .daily, now: now)

        #expect(series.values.first?.date == date(month: 9, day: 26))
        #expect(series.values.last?.date == now)
    }

    @Test("The series fills missing days and orders rows newest first")
    func series() {
        let series = ActivitySeries(points: points, metric: .daily, now: now)

        #expect(series.values.count == 30)
        #expect(series.values.map(\.value) == Array(repeating: 0, count: 27) + [100, 120, 110])
        #expect(series.rows.map(\.valueLabel) == ["110", "120", "100"] + Array(repeating: "0", count: 27))
        #expect(series.rows.first?.dayLabel == "Sun 25")
        #expect(series.rows.last?.isOldest == true)
    }

    @Test("The summary compares the latest day with the day before")
    func summary() {
        let series = ActivitySeries(points: points, metric: .daily, now: now)

        #expect(series.summary(period: .daily).valueLabel == "110")
        #expect(series.summary(period: .daily).deltaLabel(precision: 1) == "−8.3%")
        #expect(series.summary(period: .weekly).valueLabel == "1,100")
        #expect(series.summary(period: .monthly).valueLabel == "20.0K")
    }

    @Test("Stickiness divides the latest daily users by monthly users")
    func stickiness() {
        let points = [point(day: 25, dau: 100, wau: 1000, mau: 10_000)]
        let series = ActivitySeries(points: points, metric: .daily, now: now)

        #expect(series.stickinessLabel == "1.0%")
        #expect(series.daysPerMonthLabel == "0.3")
    }

    @Test("The chart scales every bar to the tallest value")
    func chartScale() {
        let series = ActivitySeries(points: points, metric: .daily, now: now)

        #expect(series.maximum == 120)
        #expect(series.rows.first?.fraction == Double(110) / 120)
    }

    @Test("The number labels stay readable")
    func numberLabels() {
        #expect(ActivityMetric(value: 1212, previous: 1000).valueLabel == "1,212")
        #expect(ActivityMetric(value: 14_259, previous: 10_000).valueLabel == "14.3K")
        #expect(ActivityMetric(value: 1041, previous: 1000).deltaLabel(precision: 1) == "+4.1%")
        #expect(ActivityMetric(value: 910, previous: 1000).deltaLabel(precision: 0) == "−9%")
        #expect(ActivityMetric(value: 1000, previous: 1000).deltaLabel(precision: 0) == "0%")
    }

    private var points: [ActivityPoint] {
        [
            point(day: 23, dau: 100, wau: 1000, mau: 20_000),
            point(day: 24, dau: 120, wau: 1000, mau: 20_000),
            point(day: 25, dau: 110, wau: 1100, mau: 20_000),
        ]
    }

    private func point(day: Int, dau: Int, wau: Int, mau: Int) -> ActivityPoint {
        ActivityPoint(
            date: date(month: 10, day: day).millisecondsSince1970,
            dau: dau,
            wau: wau,
            mau: mau
        )
    }

    private func date(month: Int, day: Int) -> Date {
        Date(year: 2026, month: month, day: day)
    }
}
