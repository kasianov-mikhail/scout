//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Int {
    /// Returns a string representation of the integer.
    ///
    /// Examples:
    /// - `1` -> `"1"`
    /// - `123456` -> `"123 456"`
    ///
    var plain: String {
        "\(self)"
    }
}

extension Double {
    /// Returns a non-localized, human-friendly decimal string for the double value.
    ///
    /// Examples:
    /// - `0.009`   -> `"0.009"`
    /// - `0.0094`  -> `"0.009"`
    /// - `0.0096`  -> `"0.010"`
    /// - `12.3`    -> `"12.3"`
    /// - `12.345`  -> `"12.35"`
    /// - `999.995` -> `"1 000.0"`
    /// - `1234.56` -> `"1 234.6"`
    ///
    /// - Important: The output is intentionally non-localized to ensure consistent decimal and grouping separators.
    ///
    var decimal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = " "

        switch self {
        case 0:
            return "0.0"
        case ..<0.01:
            formatter.minimumFractionDigits = 3
            formatter.maximumFractionDigits = 3
        case ..<1_000:
            formatter.minimumFractionDigits = 1
            formatter.maximumFractionDigits = 2
        default:
            formatter.minimumFractionDigits = 1
            formatter.maximumFractionDigits = 1
        }

        return formatter.string(from: NSNumber(value: self))!
    }
}

extension TimeInterval {
    /// Returns a concise, human-readable duration string for the time interval (in seconds).
    ///
    /// Examples:
    /// - `0.00045`    -> `"450 µs"`
    /// - `0.123`      -> `"123 ms"`
    /// - `12.34`      -> `"12.3 s"`
    /// - `125`        -> `"2 min 5 s"`
    /// - `7200`       -> `"2 h"`
    /// - `172800    ` -> `"2 d"`
    /// - `5_184_000`  -> `"2 mo"`
    /// - `47_304_000` -> `"1.5 y"`
    ///
    var duration: String {
        switch self {
        case 0:
            "0"
        case ..<0.001:
            String(format: "%.0f µs", self * 1_000_000)
        case ..<1:
            String(format: "%.0f ms", self * 1_000)
        case ..<(.minute):
            String(format: "%.1f s", self)
        case ..<(.hour):
            String(format: "%d min %d s", Int(rounded()) / Int(.minute), Int(rounded()) % Int(.minute))
        case ..<(.day):
            String(format: "%.0f h", self / .hour)
        case ..<(.month):
            String(format: "%.0f d", self / .day)
        case ..<(.year):
            String(format: "%.0f mo", self / .month)
        default:
            String(format: "%.1f y", self / .year)
        }
    }
}
