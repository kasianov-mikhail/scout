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

@Suite("LatencyHistogram")
struct LatencyHistogramTests {
    @Test("Empty histogram has no percentiles")
    func empty() {
        #expect(LatencyHistogram().percentile(0.99) == nil)
        #expect(LatencyHistogram().total == 0)
    }

    @Test("Percentile interpolates within a bucket")
    func interpolation() {
        var histogram = LatencyHistogram()
        histogram.add(count: 100, at: 0)

        #expect(histogram.percentile(0.5) == 0.0005)
        #expect(histogram.percentile(1) == 0.001)
    }

    @Test("Percentile walks buckets by cumulative count")
    func cumulative() throws {
        var histogram = LatencyHistogram()
        histogram.add(count: 90, at: 0)
        histogram.add(count: 10, at: 5)

        let p99 = try #require(histogram.percentile(0.99))

        #expect(abs(p99 - 0.0475) < 0.0001)
    }

    @Test("Overflow bucket clamps to the last finite bound")
    func overflow() {
        var histogram = LatencyHistogram()
        histogram.add(count: 10, at: LatencyBuckets.boundsMilliseconds.count)

        #expect(histogram.percentile(0.99) == 30)
    }

    @Test("Adding histograms sums counts per bucket")
    func addition() {
        var first = LatencyHistogram()
        first.add(count: 3, at: 1)
        var second = LatencyHistogram()
        second.add(count: 4, at: 1)
        second.add(count: 5, at: 2)

        let sum = first + second

        #expect(sum.counts[1] == 7)
        #expect(sum.counts[2] == 5)
        #expect(sum.total == 12)
    }

    @Test("Out-of-range indices are ignored")
    func outOfRange() {
        var histogram = LatencyHistogram()
        histogram.add(count: 5, at: -1)
        histogram.add(count: 5, at: LatencyBuckets.categories.count)

        #expect(histogram.total == 0)
    }
}
