//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct SparklineScale: Equatable {
    static let padding = 0.15

    let bottom: Double
    let top: Double

    init(values: [Int]) {
        let minValue = Double(values.min() ?? 0)
        let maxValue = Double(values.max() ?? 1)

        let padding = max(maxValue - minValue, 1) * Self.padding

        bottom = minValue - padding
        top = maxValue + padding
    }
}

extension SparklineScale {
    var domain: ClosedRange<Double> {
        bottom...top
    }
}
