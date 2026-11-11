//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import ScoutUI
@testable import Support

@Suite("MetricRange")
struct MetricRangeTests {
    private let now = Date(year: 2026, month: 6, day: 10, hour: 14, minute: 30)

    @Test("Day ranges cover the full day and the matching hour buckets")
    func dayRanges() {
        #expect(MetricRange.today.range(now: now) == Date(year: 2026, month: 6, day: 10)..<Date(year: 2026, month: 6, day: 11))
        #expect(MetricRange.yesterday.range(now: now) == Date(year: 2026, month: 6, day: 9)..<Date(year: 2026, month: 6, day: 10))
        #expect(MetricRange.today.buckets(now: now).count == 24)
        #expect(MetricRange.yesterday.buckets(now: now).count == 24)
    }

    @Test("Multi-day ranges include today")
    func multiDayRanges() {
        #expect(MetricRange.week.range(now: now) == Date(year: 2026, month: 6, day: 4)..<Date(year: 2026, month: 6, day: 11))
        #expect(MetricRange.month.range(now: now) == Date(year: 2026, month: 5, day: 12)..<Date(year: 2026, month: 6, day: 11))
        #expect(MetricRange.week.buckets(now: now).count == 7)
        #expect(MetricRange.month.buckets(now: now).count == 30)
    }

    @Test("The year splits into twelve whole months")
    func yearRange() {
        let range = MetricRange.year.range(now: now)

        #expect(range == Date(year: 2025, month: 7, day: 1)..<Date(year: 2026, month: 7, day: 1))
        #expect(MetricRange.year.buckets(now: now).count == 12)
    }

    @Test("The elapsed window stops at the current moment")
    func elapsedWindow() {
        #expect(MetricRange.today.elapsedRange(now: now) == Date(year: 2026, month: 6, day: 10)..<now)
        #expect(MetricRange.today.elapsedPreviousRange(now: now) == Date(year: 2026, month: 6, day: 9)..<Date(year: 2026, month: 6, day: 9, hour: 14, minute: 30))
        #expect(MetricRange.yesterday.elapsedRange(now: now) == MetricRange.yesterday.range(now: now))
    }

    @Test("A bucket shifts by one full period")
    func bucketShift() {
        let bucket = Date(year: 2026, month: 6, day: 10, hour: 13)..<Date(year: 2026, month: 6, day: 10, hour: 14)

        #expect(MetricRange.today.shifted(bucket) == Date(year: 2026, month: 6, day: 9, hour: 13)..<Date(year: 2026, month: 6, day: 9, hour: 14))
        #expect(MetricRange.week.shifted(Date(year: 2026, month: 6, day: 10)..<Date(year: 2026, month: 6, day: 11)) == Date(year: 2026, month: 6, day: 3)..<Date(year: 2026, month: 6, day: 4))
    }

    @Test("Current and future buckets follow the component")
    func currentAndFuture() {
        #expect(MetricRange.today.isCurrent(date: Date(year: 2026, month: 6, day: 10, hour: 14), now: now))
        #expect(!MetricRange.today.isCurrent(date: Date(year: 2026, month: 6, day: 10, hour: 13), now: now))
        #expect(MetricRange.today.isFuture(date: Date(year: 2026, month: 6, day: 10, hour: 15), now: now))
        #expect(!MetricRange.yesterday.isCurrent(date: Date(year: 2026, month: 6, day: 9, hour: 14), now: now))
    }

    @Test("Labels follow the granularity")
    func labels() {
        #expect(MetricRange.today.rowLabel(date: Date(year: 2026, month: 6, day: 10, hour: 13)) == "13:00")
        #expect(
            MetricRange.today.axisLabels(now: now) == [
                MetricAxisLabel(text: "00:00", position: 0),
                MetricAxisLabel(text: "06:00", position: 0.25),
                MetricAxisLabel(text: "12:00", position: 0.5),
                MetricAxisLabel(text: "18:00", position: 0.75),
                MetricAxisLabel(text: "24:00", position: 1),
            ]
        )
        #expect(MetricRange.year.axisLabels(now: now).count == 6)
    }

    @Test("Day axis labels mark the edges of the plot")
    func dayAxisLabelPositions() {
        #expect(MetricRange.today.axisLabels(now: now).map(\.position) == [0, 0.25, 0.5, 0.75, 1])
        #expect(MetricRange.yesterday.axisLabels(now: now).map(\.position) == [0, 0.25, 0.5, 0.75, 1])
    }

    @Test("Axis labels sit over the center of their bucket")
    func axisLabelPositions() {
        #expect(MetricRange.week.axisLabels(now: now).map(\.position) == [1.0 / 14, 5.0 / 14, 9.0 / 14, 13.0 / 14])
        #expect(MetricRange.month.axisLabels(now: now).map(\.position) == [0.5 / 30, 7.5 / 30, 14.5 / 30, 21.5 / 30, 29.5 / 30])
        #expect(MetricRange.year.axisLabels(now: now).map(\.position) == [0.5 / 12, 2.5 / 12, 4.5 / 12, 6.5 / 12, 8.5 / 12, 10.5 / 12])
    }
}
