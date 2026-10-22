//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension Int {
    var plain: String {
        "\(self)"
    }
}

extension Double {
    var decimal: String {
        let formatter: NumberFormatter
        switch self {
        case 0:
            return "0.0"
        case ..<0.01:
            formatter = .smallDecimal
        case ..<1_000:
            formatter = .midDecimal
        default:
            formatter = .largeDecimal
        }
        return formatter.string(from: NSNumber(value: self))!
    }
}

extension TimeInterval {
    var duration: String {
        if self == 0 {
            return "0"
        }
        if self < 0.001 {
            let microseconds = (self * 1_000_000).rounded()
            if microseconds < 1_000 {
                return String(format: "%.0f µs", microseconds)
            }
        }
        if self < 1 {
            let milliseconds = (self * 1_000).rounded()
            if milliseconds < 1_000 {
                return String(format: "%.0f ms", milliseconds)
            }
        }
        if self < .minute {
            let seconds = (self * 10).rounded() / 10
            if seconds < .minute {
                return String(format: "%.1f s", seconds)
            }
        }
        if self < .hour {
            let seconds = Int(rounded())
            if seconds < Int(.hour) {
                return String(format: "%d min %d s", seconds / Int(.minute), seconds % Int(.minute))
            }
        }
        if self < .day {
            let hours = (self / .hour).rounded()
            if hours < .day / .hour {
                return String(format: "%.0f h", hours)
            }
        }
        if self < .month {
            let days = (self / .day).rounded()
            if days < .month / .day {
                return String(format: "%.0f d", days)
            }
        }
        if self < .year {
            return String(format: "%.0f mo", (self / .month).rounded())
        }
        return String(format: "%.1f y", self / .year)
    }
}

extension NumberFormatter {
    fileprivate static let smallDecimal = decimal(minimumFractionDigits: 3, maximumFractionDigits: 3)
    fileprivate static let midDecimal = decimal(minimumFractionDigits: 1, maximumFractionDigits: 2)
    fileprivate static let largeDecimal = decimal(minimumFractionDigits: 1, maximumFractionDigits: 1)

    fileprivate static func decimal(minimumFractionDigits: Int, maximumFractionDigits: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = " "
        formatter.minimumFractionDigits = minimumFractionDigits
        formatter.maximumFractionDigits = maximumFractionDigits
        return formatter
    }
}
