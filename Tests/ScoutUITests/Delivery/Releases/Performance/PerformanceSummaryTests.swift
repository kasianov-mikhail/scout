//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout
@testable import ScoutUI

@Suite("PerformanceSummary")
struct PerformanceSummaryTests {
    private let range = Date(timeIntervalSince1970: 0)..<Date(timeIntervalSince1970: 700_000)

    @Test("Launch time is the median of the launch grid")
    func launchMedian() {
        let summary = PerformanceSummary(
            series: [
                makeSeries(.launchTime, category: "100", count: 2),
                makeSeries(.launchTime, category: "300", count: 2),
            ],
            range: range
        )

        #expect(summary.launchTime == 200)
    }

    @Test("Launches past the grid fall into its last cell")
    func slowLaunchesClamp() {
        let summary = PerformanceSummary(series: [makeSeries(.launchTime, category: "25000", count: 1)], range: range)

        #expect(summary.launchHistogram.counts.last == 1)
    }

    @Test("Hang rate is seconds of hangs per foreground hour")
    func hangRate() {
        let summary = PerformanceSummary(
            series: [
                makeSeries(.hangTime, count: 9_000),
                makeSeries(.foregroundTime, count: 7_200),
            ],
            range: range
        )

        #expect(summary.hangRate == 4.5)
    }

    @Test("Peak memory is the median of the device cells")
    func peakMemoryMedian() {
        let summary = PerformanceSummary(series: [makeSeries(.peakMemory, category: "150", count: 4)], range: range)

        #expect(summary.peakMemory == 175)
    }

    @Test("Points outside the range and other names are left out")
    func outsidePointsIgnored() {
        let outside = MetricSeries(
            name: PerformanceMetric.launchTime.rawValue,
            category: "100",
            version: "1.0",
            points: [MetricSeriesPoint(date: range.upperBound, value: 5)]
        )
        let summary = PerformanceSummary(series: [outside, makeSeries(name: "exit", count: 3)], range: range)

        #expect(summary.isEmpty)
        #expect(summary.launchTime == nil)
        #expect(summary.hangRate == nil)
    }

    private func makeSeries(_ metric: PerformanceMetric, category: String? = nil, count: Int) -> MetricSeries {
        makeSeries(name: metric.rawValue, category: category, count: count)
    }

    private func makeSeries(name: String, category: String? = nil, count: Int) -> MetricSeries {
        MetricSeries(
            name: name,
            category: category,
            version: "1.0",
            points: [MetricSeriesPoint(date: range.lowerBound, value: Double(count))]
        )
    }
}
