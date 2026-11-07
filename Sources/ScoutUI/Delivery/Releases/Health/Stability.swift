//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct Stability: Ratio {
    let value: Double

    init(_ value: Double) {
        self.value = value
    }

    var level: Level {
        switch value {
        case 0.995...: .healthy
        case 0.99..<0.995: .watch
        case 0.98..<0.99: .atRisk
        default: .critical
        }
    }

    var color: Color {
        level.color
    }

    var formatted: String {
        percentage(fractionDigits: 2)
    }
}

extension Stability {
    enum Level: CaseIterable, Hashable {
        case healthy
        case watch
        case atRisk
        case critical

        var title: String {
            switch self {
            case .healthy: "Healthy"
            case .watch: "Watch"
            case .atRisk: "At risk"
            case .critical: "Critical"
            }
        }

        var color: Color {
            switch self {
            case .healthy: .green
            case .watch: .yellow
            case .atRisk: .orange
            case .critical: .red
            }
        }

        var tint: Color {
            switch self {
            case .healthy: Color(red: 0x1E / 255, green: 0x7D / 255, blue: 0x34 / 255)
            case .watch: Color(red: 0x8A / 255, green: 0x6D / 255, blue: 0x00 / 255)
            case .atRisk: Color(red: 0xB3 / 255, green: 0x5C / 255, blue: 0x00 / 255)
            case .critical: Color(red: 0xC4 / 255, green: 0x00 / 255, blue: 0x1A / 255)
            }
        }

        var background: Color {
            switch self {
            case .healthy: Color(red: 0xE9 / 255, green: 0xF8 / 255, blue: 0xEE / 255)
            case .watch: Color(red: 0xFF / 255, green: 0xF8 / 255, blue: 0xDB / 255)
            case .atRisk: Color(red: 0xFF / 255, green: 0xF1 / 255, blue: 0xE0 / 255)
            case .critical: Color(red: 0xFF / 255, green: 0xEB / 255, blue: 0xEA / 255)
            }
        }

        var border: Color {
            switch self {
            case .healthy: Color(red: 0xC5 / 255, green: 0xE8 / 255, blue: 0xCF / 255)
            case .watch: Color(red: 0xF0 / 255, green: 0xE2 / 255, blue: 0xA8 / 255)
            case .atRisk: Color(red: 0xF3 / 255, green: 0xD2 / 255, blue: 0xA9 / 255)
            case .critical: Color(red: 0xF3 / 255, green: 0xC1 / 255, blue: 0xBE / 255)
            }
        }
    }
}

extension Stability {
    init(of affected: Int, in total: Int) {
        if total > 0 {
            value = max(0, 1 - Double(affected) / Double(total))
        } else if affected > 0 {
            value = 0
        } else {
            value = 1
        }
    }

    static func optional(of affected: Int, in total: Int) -> Stability? {
        total > 0 ? Stability(of: affected, in: total) : nil
    }
}
