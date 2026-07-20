//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct MetricReading: Equatable {
    let baseline: Double
    let recent: [Double]
}

extension MetricReading {
    func reference(for reference: AlertCondition.Reference) -> Double? {
        switch reference {
        case .constant(let value):
            value
        case .baselineFactor(let factor):
            baseline > 0 ? baseline * factor : nil
        case .medianFactor(let factor):
            recent.median.map { $0 * factor }
        }
    }
}

extension [Double] {
    var median: Double? {
        guard count > 0 else { return nil }

        let sorted = sorted()
        let middle = count / 2

        guard count.isMultiple(of: 2) else {
            return sorted[middle]
        }
        return (sorted[middle - 1] + sorted[middle]) / 2
    }
}
