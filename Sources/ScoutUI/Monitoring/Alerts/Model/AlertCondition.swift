//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct AlertCondition: Hashable, Codable {
    let comparison: Comparison
    let reference: Reference
}

extension AlertCondition {
    enum Comparison: Hashable, Codable {
        case below
        case above
    }

    enum Reference: Hashable, Codable {
        case constant(Double)
        case baselineFactor(Double)
        case medianFactor(Double)
    }
}

extension AlertCondition {
    func isBreached(by value: Double, in reading: MetricReading) -> Bool {
        guard let reference = reading.reference(for: reference) else { return false }

        switch comparison {
        case .below:
            return value < reference
        case .above:
            return value > reference
        }
    }
}
