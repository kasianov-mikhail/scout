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

@Suite("MetricTimeline")
struct MetricTimelineTests {
    private let now = Date(year: 2026, month: 6, day: 10, hour: 11, minute: 30)
    private let timeline = MetricTimeline(points: [
        ChartPoint(date: Date(year: 2026, month: 6, day: 10, hour: 9), value: 2),
        ChartPoint(date: Date(year: 2026, month: 6, day: 10, hour: 10, minute: 30), value: 3),
        ChartPoint(date: Date(year: 2026, month: 6, day: 10, hour: 11), value: 4),
        ChartPoint(date: Date(year: 2026, month: 6, day: 9, hour: 9), value: 1),
    ])

    @Test("Hourly buckets sum the current and previous day")
    func buckets() {
        let buckets = timeline.buckets(range: .today, now: now, fold: .total)

        #expect(buckets.count == 24)
        #expect(buckets[9].value == 2)
        #expect(buckets[10].value == 3)
        #expect(buckets[11].value == 4)
        #expect(buckets[9].previous == 1)
        #expect(buckets[11].isCurrent)
        #expect(buckets[12].value == nil)
    }

    @Test("Peak keeps the largest sample in the bucket")
    func peakFold() {
        let peak = MetricTimeline(points: [
            ChartPoint(date: Date(year: 2026, month: 6, day: 10, hour: 9), value: 2),
            ChartPoint(date: Date(year: 2026, month: 6, day: 10, hour: 9, minute: 20), value: 5),
            ChartPoint(date: Date(year: 2026, month: 6, day: 10, hour: 9, minute: 40), value: 3),
        ])

        let buckets = peak.buckets(range: .today, now: now, fold: .peak)

        #expect(buckets[9].value == 5)
    }

    @Test("Summary compares the elapsed windows")
    func summary() {
        let summary = timeline.summary(range: .today, now: now, format: .counter)

        #expect(summary.value == "9")
        #expect(summary.unit == "total today")
        #expect(summary.detail == "+800% vs yesterday at this hour")
        #expect(summary.tone == .positive)
    }

    @Test("A gauge reports the latest value and the peak")
    func gaugeSummary() {
        let summary = timeline.gaugeSummary(range: .today, now: now, format: .counter)

        #expect(summary.value == "4")
        #expect(summary.detail == "peak today 4 at 11:00")
    }

    @Test("Data is detected only inside the selected period")
    func containsData() {
        #expect(timeline.containsData(range: .today, now: now))
        #expect(timeline.containsData(range: .yesterday, now: now))
        #expect(!timeline.containsData(range: .week, now: Date(year: 2026, month: 7, day: 1)))
    }
}
