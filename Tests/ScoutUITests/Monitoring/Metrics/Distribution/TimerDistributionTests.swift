//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout
import Testing

@testable import ScoutUI
@testable import Support

@Suite("TimerDistribution")
struct TimerDistributionTests {
    let base = Date(year: 2026, month: 6, day: 1)

    @Test("Builds histograms from bucket series and ignores foreign categories")
    func seriesInit() throws {
        let distribution = TimerDistribution(series: [
            makeSeries(category: "timer_le_1", points: [(base, 3)]),
            makeSeries(category: "timer_le_100", points: [(base, 2)]),
            makeSeries(category: "timer", points: [(base, 9)]),
        ])

        #expect(distribution.histograms.count == 1)

        let histogram = try #require(distribution.histograms[base])
        #expect(histogram.total == 5)
        #expect(histogram.counts[0] == 3)
        #expect(histogram.counts[6] == 2)
    }

    @Test("summary combines histograms within the range only")
    func summaryRange() throws {
        let inside = base
        let outside = base.adding(.day, value: 2)
        let distribution = TimerDistribution(series: [
            makeSeries(category: "timer_le_1", points: [(inside, 100)]),
            makeSeries(category: "timer_le_inf", points: [(outside, 100)]),
        ])

        let summary = try #require(distribution.summary(in: base..<base.adding(.day)))

        #expect(abs(summary.p99 - 0.00099) < 0.000001)
        #expect(summary.p50 == 0.0005)
    }

    @Test("summary is nil when the range holds no samples")
    func summaryEmpty() {
        let distribution = TimerDistribution(series: [
            makeSeries(category: "timer_le_1", points: [(base, 5)])
        ])

        #expect(distribution.summary(in: base.adding(.day)..<base.adding(.day, value: 2)) == nil)
    }

    @Test("isEmpty reflects total counts")
    func isEmpty() {
        #expect(TimerDistribution(series: []).isEmpty)
        #expect(!TimerDistribution(series: [makeSeries(category: "timer_le_1", points: [(base, 1)])]).isEmpty)
    }

    private func makeSeries(category: String, points: [(Date, Int)]) -> MetricSeries {
        MetricSeries(
            name: "http_request",
            category: category,
            points: points.map { date, count in
                MetricSeriesPoint(date: date, value: Double(count))
            }
        )
    }
}
