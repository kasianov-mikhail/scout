//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Testing

@testable import Scout
@testable import ScoutUI
@testable import Support

@Suite("RecorderHistogram")
struct RecorderHistogramTests {
    @Test("Empty histogram has no percentiles")
    func empty() {
        #expect(RecorderHistogram().percentile(0.99) == nil)
        #expect(RecorderHistogram().total == 0)
    }

    @Test("Percentile interpolates within a bucket")
    func interpolation() {
        var histogram = RecorderHistogram()
        histogram.add(count: 100, at: 0)

        #expect(histogram.percentile(0.5) == 0.5)
        #expect(histogram.percentile(1) == 1)
    }

    @Test("Percentile walks buckets by cumulative count")
    func cumulative() throws {
        var histogram = RecorderHistogram()
        histogram.add(count: 90, at: 0)
        histogram.add(count: 10, at: 6)

        let p99 = try #require(histogram.percentile(0.99))

        #expect(abs(p99 - 95) < 0.001)
    }

    @Test("Overflow bucket clamps to the last finite bound")
    func overflow() {
        var histogram = RecorderHistogram()
        histogram.add(count: 10, at: RecorderBuckets.bounds.count)

        #expect(histogram.percentile(0.99) == 1_000_000)
    }

    @Test("Adding histograms sums counts per bucket")
    func addition() {
        var first = RecorderHistogram()
        first.add(count: 3, at: 1)
        var second = RecorderHistogram()
        second.add(count: 4, at: 1)
        second.add(count: 5, at: 2)

        let sum = first + second

        #expect(sum.counts[1] == 7)
        #expect(sum.counts[2] == 5)
        #expect(sum.total == 12)
    }

    @Test("Out-of-range indices are ignored")
    func outOfRange() {
        var histogram = RecorderHistogram()
        histogram.add(count: 5, at: -1)
        histogram.add(count: 5, at: RecorderBuckets.categories.count)

        #expect(histogram.total == 0)
    }

    @Test("Distribution builds from recorder bucket series and ignores foreign categories")
    func distribution() throws {
        let base = Date(year: 2026, month: 6, day: 1)
        let distribution = RecorderDistribution(series: [
            makeSeries(category: "recorder_le_1", date: base, count: 100),
            makeSeries(category: "recorder", date: base, count: 42),
        ])

        let summary = try #require(distribution.summary(in: base..<base.adding(.day)))

        #expect(summary.p50 == 0.5)
        #expect(distribution.total(in: base..<base.adding(.day)) == 100)
    }

    private func makeSeries(category: String, date: Date, count: Int) -> MetricSeries {
        MetricSeries(
            name: "payload_size",
            category: category,
            points: [MetricSeriesPoint(date: date.millisecondsSince1970, value: .int(count))]
        )
    }
}
