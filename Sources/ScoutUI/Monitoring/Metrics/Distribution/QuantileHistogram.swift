//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

protocol QuantileHistogram: MetricHistogram, Equatable {
    static var bounds: [Double] { get }
}

extension QuantileHistogram {
    func percentile(_ quantile: Double) -> Double? {
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

    private func interpolated(at index: Int, fraction: Double) -> Double {
        let bounds = Self.bounds
        let lower = index == 0 ? 0 : bounds[index - 1]
        let upper = index < bounds.count ? bounds[index] : bounds[bounds.count - 1]
        return lower + (upper - lower) * min(max(fraction, 0), 1)
    }
}
