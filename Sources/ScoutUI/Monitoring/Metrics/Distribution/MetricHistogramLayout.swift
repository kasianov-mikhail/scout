//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct MetricHistogramLayout {
    let bounds: [Double]
    let maximum: Int

    init(counts: [Int], bounds: [Double]) {
        self.bounds = bounds
        self.maximum = counts.max() ?? 0
    }

    var labelIndices: [Int] {
        let total = bounds.count + 1
        let step = max(1, Int(ceil(Double(total) / 8)))
        return Array(stride(from: 0, to: total, by: step))
    }

    func fraction(_ count: Int) -> Double {
        maximum > 0 ? Double(count) / Double(maximum) : 0
    }

    func position(_ value: Double) -> Double {
        guard !bounds.isEmpty else {
            return 0
        }
        guard value > 0 else {
            return 0
        }

        let index = bounds.firstIndex { value <= $0 } ?? bounds.count

        guard index < bounds.count else {
            return 1
        }

        let lower = index == 0 ? 0 : bounds[index - 1]
        let upper = bounds[index]
        let fraction: Double

        if lower > 0, upper > lower {
            fraction = log(value / lower) / log(upper / lower)
        } else {
            fraction = (value - lower) / (upper - lower)
        }

        return (Double(index) + min(max(fraction, 0), 1)) / Double(bounds.count + 1)
    }

    func label(at index: Int, format: MetricHistogramFormat) -> String {
        guard index < bounds.count else {
            return format.overflowLabel(bounds.last ?? 0)
        }
        return format.label(bounds[index])
    }
}
