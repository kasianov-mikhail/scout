//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct MetricChartScale {
    let upper: Double
    let ticks: [Double]

    init(values: [Double]) {
        let maximum = values.filter(\.isFinite).max() ?? 0

        guard maximum > 0 else {
            upper = 1
            ticks = []
            return
        }

        let magnitude = pow(10, floor(log10(maximum / 4)))
        let candidates = [1.0, 2.0, 2.5, 5.0, 10.0].map { $0 * magnitude }
        let steps = candidates.filter { step in
            let count = Int(ceil(maximum / step))
            return count >= 2 && count <= 5
        }
        let step =
            steps.min { lhs, rhs in
                abs(Int(ceil(maximum / lhs)) - 4) < abs(Int(ceil(maximum / rhs)) - 4)
            } ?? magnitude

        upper = ceil(maximum / step) * step
        ticks = (1...Int((upper / step).rounded())).map { Double($0) * step }
    }
}
