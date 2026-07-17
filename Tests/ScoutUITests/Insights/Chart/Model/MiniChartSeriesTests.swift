//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout
@testable import ScoutTestSupport
@testable import ScoutUI

struct MiniChartSeriesTests {
    /// Seven days, so each slice spans exactly one day.
    let range = Date(year: 2026, month: 6, day: 1)..<Date(year: 2026, month: 6, day: 8)

    private func makePoint(day: Int, hour: Int = 0, count: Int) -> ChartPoint<Int> {
        ChartPoint(date: Date(year: 2026, month: 6, day: day, hour: hour), count: count)
    }

    @Test("Empty points produce sliceCount zeros")
    func emptyPoints() {
        let series = MiniChartSeries(points: [], range: range, aggregation: .total)
        #expect(series.values == Array(repeating: 0, count: MiniChartSeries.sliceCount))
    }

    @Test("Points land in their slice, oldest first")
    func slicing() {
        let points = [makePoint(day: 1, count: 1), makePoint(day: 4, count: 5)]
        let series = MiniChartSeries(points: points, range: range, aggregation: .total)

        #expect(series.values == [1, 0, 0, 5, 0, 0, 0])
    }

    @Test("A point on a slice boundary belongs to the later slice")
    func sliceBoundary() {
        let series = MiniChartSeries(points: [makePoint(day: 2, count: 7)], range: range, aggregation: .total)
        #expect(series.values == [0, 7, 0, 0, 0, 0, 0])
    }

    @Test("Points outside the range are ignored")
    func outsideRange() {
        let points = [
            ChartPoint(date: Date(year: 2026, month: 5, day: 31), count: 9),
            ChartPoint(date: range.upperBound, count: 9),
            makePoint(day: 1, count: 1),
        ]
        let series = MiniChartSeries(points: points, range: range, aggregation: .total)

        #expect(series.values == [1, 0, 0, 0, 0, 0, 0])
    }

    @Test("A range not divisible by sliceCount still spans all slices")
    func unevenRange() {
        let range = Date(year: 2026, month: 5, day: 9)..<Date(year: 2026, month: 6, day: 8)
        let points = [
            ChartPoint(date: range.lowerBound, count: 1),
            ChartPoint(date: range.upperBound.addingTimeInterval(-1), count: 2),
        ]
        let series = MiniChartSeries(points: points, range: range, aggregation: .total)

        #expect(series.values == [1, 0, 0, 0, 0, 0, 2])
    }

    @Test("An empty range produces zeros instead of crashing")
    func emptyRange() {
        let date = Date(year: 2026, month: 6, day: 1)
        let series = MiniChartSeries(points: [makePoint(day: 1, count: 5)], range: date..<date, aggregation: .total)

        #expect(series.values == Array(repeating: 0, count: MiniChartSeries.sliceCount))
    }

    @Test("Total sums all points in a slice")
    func totalAggregation() {
        let points = [makePoint(day: 1, hour: 3, count: 1), makePoint(day: 1, hour: 12, count: 2)]
        let series = MiniChartSeries(points: points, range: range, aggregation: .total)

        #expect(series.values == [3, 0, 0, 0, 0, 0, 0])
    }

    @Test("Latest picks the newest point in a slice")
    func latestAggregation() {
        let points = [makePoint(day: 1, hour: 3, count: 10), makePoint(day: 1, hour: 20, count: 4)]
        let series = MiniChartSeries(points: points, range: range, aggregation: .latest)

        #expect(series.values == [4, 0, 0, 0, 0, 0, 0])
    }

    @Test("Latest aggregates each slice independently")
    func latestPerSlice() {
        let points = [
            makePoint(day: 1, hour: 3, count: 10),
            makePoint(day: 1, hour: 20, count: 4),
            makePoint(day: 5, count: 9),
        ]
        let series = MiniChartSeries(points: points, range: range, aggregation: .latest)

        #expect(series.values == [4, 0, 0, 0, 9, 0, 0])
    }

    @Test("An all-zero series counts as empty")
    func allZeroIsEmpty() {
        let series = MiniChartSeries(points: [], range: range, aggregation: .total)

        #expect(series.isEmpty)
        #expect(MiniChartSeries.empty.isEmpty)
    }

    @Test("A series with any value is not empty")
    func nonZeroIsNotEmpty() {
        let series = MiniChartSeries(points: [makePoint(day: 1, count: 1)], range: range, aggregation: .total)

        #expect(!series.isEmpty)
    }
}
