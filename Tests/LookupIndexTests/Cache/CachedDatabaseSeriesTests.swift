//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import LookupIndex
@testable import Scout

struct CachedDatabaseSeriesTests {
    @Test func mergesCachedAndFetchedPointsUnderTheSameKey() {
        let cached = [makeSeries(points: [makePoint(date: 2)])].cacheRecords
        let fetched = [makeSeries(points: [makePoint(date: 1)])]

        let series = MetricSeries.combined(cached: cached, fetched: fetched)

        #expect(series.count == 1)
        #expect(series.first?.points.map(\.date.millisecondsSince1970) == [1, 2])
    }

    @Test func keepsSeriesWithDifferentKeysApart() {
        let fetched = [
            makeSeries(points: [makePoint(date: 1)], version: "1.0"),
            makeSeries(points: [makePoint(date: 1)], version: "1.1"),
            makeSeries(points: [makePoint(date: 1)], category: "billing"),
        ]

        #expect(MetricSeries.combined(cached: [], fetched: fetched).count == 3)
    }

    @Test func sortsSeriesByNameThenCategoryThenVersion() {
        let fetched = [
            makeSeries(points: [makePoint(date: 1)], name: "Session", version: "1.1"),
            makeSeries(points: [makePoint(date: 1)], name: "Session", version: "1.0"),
            makeSeries(points: [makePoint(date: 1)], name: "Session", category: "billing"),
            makeSeries(points: [makePoint(date: 1)], name: "Crash"),
        ]

        let keys = MetricSeries.combined(cached: [], fetched: fetched).map { [$0.name, $0.category ?? "", $0.version ?? ""] }
        #expect(
            keys == [
                ["Crash", "", ""],
                ["Session", "", "1.0"],
                ["Session", "", "1.1"],
                ["Session", "billing", ""],
            ]
        )
    }

    @Test func roundTripsIntAndDoubleValues() {
        let stored = [
            makeSeries(points: [MetricSeriesPoint(date: Date(millisecondsSince1970: 1), value: 3)], name: "Count"),
            makeSeries(points: [MetricSeriesPoint(date: Date(millisecondsSince1970: 1), value: 0.5)], name: "Latency"),
        ]

        let series = MetricSeries.combined(cached: stored.cacheRecords, fetched: [])

        #expect(series.map { $0.points.map(\.value) } == [[3], [0.5]])
    }

    @Test func readsAnIntegerValueStoredByAnOlderCache() {
        var record = Record(recordType: "MetricSeriesPoint", recordID: "legacy")
        record.fields["date"] = .date(Date(millisecondsSince1970: 1_000))
        record.fields["name"] = .string("Session")
        record.fields["value"] = .int(3)

        let series = MetricSeries.combined(cached: [record], fetched: [])

        #expect(series.first?.points.map(\.value) == [3])
    }

    @Test func hasNoSeriesWhenNothingIsCachedOrFetched() {
        #expect(MetricSeries.combined(cached: [], fetched: []).isEmpty)
    }

    private func makePoint(date: Int64) -> MetricSeriesPoint {
        MetricSeriesPoint(date: Date(millisecondsSince1970: date), value: 1)
    }

    private func makeSeries(points: [MetricSeriesPoint], name: String = "Session", category: String? = nil, version: String? = nil) -> MetricSeries {
        MetricSeries(name: name, category: category, version: version, points: points)
    }
}
