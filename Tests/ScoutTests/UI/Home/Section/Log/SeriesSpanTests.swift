//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct SeriesSpanTests {
    let range = Date(year: 2026, month: 6, day: 1)..<Date(year: 2026, month: 6, day: 8)

    @Test("Count excludes crashes and metrics")
    func countExcludesCrashesAndMetrics() {
        let span = makeSpan([
            makeSeries(name: "login", date: Date(year: 2026, month: 6, day: 2), value: 3),
            makeSeries(name: "purchase", date: Date(year: 2026, month: 6, day: 3), value: 4),
            makeSeries(name: "Crash", date: Date(year: 2026, month: 6, day: 2), value: 2),
            makeSeries(name: "api_calls", category: "counter", date: Date(year: 2026, month: 6, day: 2), value: 7),
        ])

        #expect(span.points { $0 != CrashEntry.recordType }.total == 7)
    }

    @Test("Count keeps points inside the range only")
    func countFiltersByRange() {
        let span = makeSpan([
            makeSeries(name: "login", date: Date(year: 2026, month: 6, day: 1), value: 3),
            makeSeries(name: "login", date: Date(year: 2026, month: 5, day: 20), value: 9),
            makeSeries(name: "login", date: Date(year: 2026, month: 6, day: 8), value: 5),
        ])

        #expect(span.points { $0 != CrashEntry.recordType }.total == 3)
    }

    @Test("Count sums the Crash series")
    func crashCount() {
        let span = makeSpan([
            makeSeries(name: "Crash", date: Date(year: 2026, month: 6, day: 2), value: 2),
            makeSeries(name: "Crash", date: Date(year: 2026, month: 5, day: 20), value: 4),
            makeSeries(name: "login", date: Date(year: 2026, month: 6, day: 2), value: 3),
        ])

        #expect(span.points { $0 == CrashEntry.recordType }.total == 2)
    }

    @Test("Metric count tallies distinct metrics across value flavors")
    func metricCountIsDistinct() {
        let span = makeSpan([
            makeSeries(name: "api_calls", category: "counter", date: Date(year: 2026, month: 6, day: 2), value: 7),
            makeSeries(name: "api_calls", category: "counter", date: Date(year: 2026, month: 6, day: 4), value: 1),
            makeSeries(name: "login", date: Date(year: 2026, month: 6, day: 2), value: 3),
            makeSeries(name: "load_time", category: "timer", date: Date(year: 2026, month: 6, day: 3), value: 1.5),
            makeSeries(name: "api_calls", category: "timer", date: Date(year: 2026, month: 6, day: 3), value: 1.5),
        ])

        #expect(span.metricCount == 3)
    }

    @Test("Metric count skips metrics without points in the range")
    func metricCountFiltersByRange() {
        let span = makeSpan([
            makeSeries(name: "load_time", category: "timer", date: Date(year: 2026, month: 5, day: 20), value: 1.5)
        ])

        #expect(span.metricCount == 0)
    }

    @Test("Metric count skips categories the Metrics list does not show")
    func metricCountSkipsHiddenCategories() {
        let span = makeSpan([
            makeSeries(name: "memory", category: "meter_set", date: Date(year: 2026, month: 6, day: 2), value: 1.5)
        ])

        #expect(span.metricCount == 0)
    }

    @Test("Points carry the series that pass the filter, inside the range only")
    func pointsByName() {
        let span = makeSpan([
            makeSeries(name: "login", date: Date(year: 2026, month: 6, day: 2), value: 3),
            makeSeries(name: "Crash", date: Date(year: 2026, month: 6, day: 3), value: 2),
            makeSeries(name: "login", date: Date(year: 2026, month: 5, day: 20), value: 9),
            makeSeries(name: "api_calls", category: "counter", date: Date(year: 2026, month: 6, day: 2), value: 7),
        ])

        let points = span.points { $0 != CrashEntry.recordType }

        #expect(points.map(\.count) == [3])
    }

    @Test("Points by category keep the telemetry series filed under it")
    func pointsByCategory() {
        let span = makeSpan([
            makeSeries(name: "/users", category: "status_2xx", date: Date(year: 2026, month: 6, day: 2), value: 5),
            makeSeries(name: "/users", category: "status_5xx", date: Date(year: 2026, month: 6, day: 3), value: 1),
            makeSeries(name: "/users", category: "timer_le_500", date: Date(year: 2026, month: 6, day: 3), value: 8),
            makeSeries(name: "login", date: Date(year: 2026, month: 6, day: 2), value: 3),
        ])

        let points = span.points(inCategories: Set(StatusBuckets.categories))

        #expect(points.map(\.count).sorted() == [1, 5])
        #expect(points.total == 6)
    }

    /// A span already narrowed to `range`, matching how the log section consumes it.
    private func makeSpan(_ series: [MetricSeries]) -> SeriesSpan {
        SeriesSpan(series: series, range: range)
    }

    /// A one-point series landing exactly on `date`.
    private func makeSeries(name: String, category: String? = nil, date: Date, value: Int) -> MetricSeries {
        MetricSeries(
            name: name,
            category: category,
            points: [MetricSeriesPoint(date: date.millisecondsSince1970, value: .int(value))]
        )
    }

    private func makeSeries(name: String, category: String? = nil, date: Date, value: Double) -> MetricSeries {
        MetricSeries(
            name: name,
            category: category,
            points: [MetricSeriesPoint(date: date.millisecondsSince1970, value: .double(value))]
        )
    }
}
