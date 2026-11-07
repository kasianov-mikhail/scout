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

    @Test("Every range ends on today or yesterday")
    func bounds() {
        #expect(ActivityRange.month.range(now: now) == date(month: 9, day: 26)..<date(month: 10, day: 26))
        #expect(ActivityRange.week.range(now: now) == date(month: 10, day: 19)..<date(month: 10, day: 26))
        #expect(ActivityRange.today.range(now: now) == date(month: 10, day: 25)..<date(month: 10, day: 26))
        #expect(ActivityRange.yesterday.range(now: now) == date(month: 10, day: 24)..<date(month: 10, day: 25))
        #expect(ActivityRange.year.range(now: now).lowerBound == Date(year: 2025, month: 10, day: 26))
    }

    @Test("The axis labels the first, middle and last day")
    func axis() {
        let axis = ActivityRange.month.axis(now: now)

        #expect(axis.start == "Sep 26")
        #expect(axis.middle == "Oct 10")
        #expect(axis.end == "today")
    }

    @Test("The series fills missing days and orders rows newest first")
    func series() {
        let series = ActivitySeries(points: points, range: .week, metric: .daily, now: now)

        #expect(series.values.count == 7)
        #expect(series.values.map(\.value) == [0, 0, 0, 0, 100, 120, 110])
        #expect(series.rows.map(\.valueLabel) == ["110", "120", "100", "0", "0", "0", "0"])
        #expect(series.rows.first?.dayLabel == "Sun 25")
        #expect(series.rows.last?.isOldest == true)
    }

    @Test("The summary compares the latest day with the day before")
    func summary() {
        let series = ActivitySeries(points: points, range: .week, metric: .daily, now: now)

        #expect(series.summary(period: .daily).valueLabel == "110")
        #expect(series.summary(period: .daily).deltaLabel(precision: 1) == "−8.3%")
        #expect(series.summary(period: .weekly).valueLabel == "1,100")
        #expect(series.summary(period: .monthly).valueLabel == "20.0K")
    }

    @Test("Stickiness divides the latest daily users by monthly users")
    func stickiness() {
        let points = [point(day: 25, dau: 100, wau: 1000, mau: 10_000)]
        let series = ActivitySeries(points: points, range: .week, metric: .daily, now: now)

        #expect(series.stickinessLabel == "1.0%")
        #expect(series.daysPerMonthLabel == "0.3")
    }

    @Test("The chart scales every bar to the tallest value")
    func chartScale() {
        let series = ActivitySeries(points: points, range: .week, metric: .daily, now: now)

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
