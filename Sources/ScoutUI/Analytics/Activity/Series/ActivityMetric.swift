//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct ActivityMetric {
    let value: Int
    let previous: Int?

    var valueLabel: String {
        if value < 10_000 {
            return value.formatted(.number.locale(Locale(identifier: "en_US")))
        }
        return value.compact
    }

    var isRising: Bool {
        guard let delta else { return false }
        return delta > 0
    }

    func deltaLabel(precision: Int) -> String {
        guard let delta else { return "—" }

        let scale = pow(10, Double(precision))
        let percent = (delta * 100 * scale).rounded() / scale

        guard percent != 0 else {
            return "0%"
        }

        let sign = percent > 0 ? "+" : "−"
        let magnitude = String(format: "%.\(precision)f", abs(percent))
        return sign + magnitude + "%"
    }

    private var delta: Double? {
        guard let previous else { return nil }
        guard previous > 0 else {
            return nil
        }
        return Double(value - previous) / Double(previous)
    }
}
