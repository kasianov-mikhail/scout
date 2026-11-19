//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

enum MetricHistogramFormat {
    case timer
    case recorder
}

extension MetricHistogramFormat {
    func label(_ bound: Double) -> String {
        switch self {
        case .timer:
            Self.durationLabel(bound)
        case .recorder:
            Self.countLabel(bound)
        }
    }

    func overflowLabel(_ bound: Double) -> String {
        ">" + label(bound)
    }

    private static func durationLabel(_ seconds: Double) -> String {
        let milliseconds = seconds * 1_000

        if milliseconds < 1_000 {
            return String(format: "%.0f", milliseconds)
        }

        let value = milliseconds / 1_000
        if value.rounded() == value {
            return "\(Int(value))s"
        }
        return String(format: "%.1fs", value)
    }

    private static func countLabel(_ value: Double) -> String {
        if value >= 1_000_000 {
            return compact(value / 1_000_000, "M")
        }
        if value >= 1_000 {
            return compact(value / 1_000, "k")
        }
        return String(format: "%.0f", value)
    }

    private static func compact(_ value: Double, _ suffix: String) -> String {
        value.rounded() == value ? "\(Int(value))\(suffix)" : String(format: "%.1f%@", value, suffix)
    }
}
