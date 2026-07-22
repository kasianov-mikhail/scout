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

struct SeriesGroupsTests {
    @Test func mergesPointsUnderTheSameKey() {
        var groups = SeriesGroups()
        groups.append(makePoint(date: 2), to: makeKey())
        groups.append(makeSeries(points: [makePoint(date: 1)]))

        let series = groups.series
        #expect(series.count == 1)
        #expect(series.first?.points.map(\.date) == [1, 2])
    }

    @Test func keepsSeriesWithDifferentKeysApart() {
        var groups = SeriesGroups()
        groups.append(makePoint(date: 1), to: makeKey(version: "1.0"))
        groups.append(makePoint(date: 1), to: makeKey(version: "1.1"))
        groups.append(makePoint(date: 1), to: makeKey(category: "billing"))

        #expect(groups.series.count == 3)
    }

    @Test func sortsSeriesByNameThenCategoryThenVersion() {
        var groups = SeriesGroups()
        groups.append(makePoint(date: 1), to: makeKey(name: "Session", version: "1.1"))
        groups.append(makePoint(date: 1), to: makeKey(name: "Session", version: "1.0"))
        groups.append(makePoint(date: 1), to: makeKey(name: "Session", category: "billing"))
        groups.append(makePoint(date: 1), to: makeKey(name: "Crash"))

        let keys = groups.series.map { [$0.name, $0.category ?? "", $0.version ?? ""] }
        #expect(
            keys == [
                ["Crash", "", ""],
                ["Session", "", "1.0"],
                ["Session", "", "1.1"],
                ["Session", "billing", ""],
            ]
        )
    }

    @Test func treatsMissingCategoryAndVersionAsEmpty() {
        #expect(makeKey(category: nil) < makeKey(category: "billing"))
        #expect(makeKey(version: nil) < makeKey(version: "1.0"))
        #expect(makeKey(name: "Crash") < makeKey(name: "Session", category: nil, version: nil))
    }

    @Test func hasNoSeriesWhenNothingAppended() {
        #expect(SeriesGroups().series.count == 0)
    }

    private func makeKey(name: String = "Session", category: String? = nil, version: String? = nil) -> SeriesKey {
        SeriesKey(name: name, category: category, version: version)
    }

    private func makePoint(date: Int64) -> MetricSeriesPoint {
        MetricSeriesPoint(date: date, value: .int(1))
    }

    private func makeSeries(points: [MetricSeriesPoint]) -> MetricSeries {
        MetricSeries(name: "Session", category: nil, version: nil, points: points)
    }
}
