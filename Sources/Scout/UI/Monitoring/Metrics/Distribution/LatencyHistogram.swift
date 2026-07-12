//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

struct LatencyHistogram: Equatable {
    private(set) var counts: [Int]

    init() {
        counts = Array(repeating: 0, count: LatencyBuckets.categories.count)
    }

    var total: Int {
        counts.reduce(0, +)
    }

    mutating func add(count: Int, at index: Int) {
        guard counts.indices.contains(index) else { return }
        counts[index] += count
    }

    static func + (lhs: LatencyHistogram, rhs: LatencyHistogram) -> LatencyHistogram {
        var sum = LatencyHistogram()
        sum.counts = zip(lhs.counts, rhs.counts).map(+)
        return sum
    }

    func percentile(_ quantile: Double) -> TimeInterval? {
        guard total > 0 else { return nil }

        let target = Double(total) * quantile
        var cumulative = 0

        for (index, count) in counts.enumerated() where count > 0 {
            let previous = cumulative
            cumulative += count

            if Double(cumulative) >= target {
                let fraction = (target - Double(previous)) / Double(count)
                return interpolated(at: index, fraction: fraction)
            }
        }

        return Self.bounds.last
    }

    private static let bounds = LatencyBuckets.boundsMilliseconds.map { TimeInterval($0) / 1_000 }

    private func interpolated(at index: Int, fraction: Double) -> TimeInterval {
        let bounds = Self.bounds
        let lower = index == 0 ? 0 : bounds[index - 1]
        let upper = index < bounds.count ? bounds[index] : bounds[bounds.count - 1]
        return lower + (upper - lower) * min(max(fraction, 0), 1)
    }
}

extension LatencyHistogram: MetricHistogram {
    static func bucketIndex(of category: String) -> Int? {
        LatencyBuckets.index(of: category)
    }
}
