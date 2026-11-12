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
            case .healthy: "healthy"
            case .watch: "watch"
            case .atRisk: "at risk"
            case .critical: "critical"
            }
        }

        var displayTitle: String {
            title.prefix(1).uppercased() + title.dropFirst()
        }

        var color: Color {
            switch self {
            case .healthy: .fillSuccess
            case .watch: .fillCaution
            case .atRisk: .fillWarning
            case .critical: .fillDanger
            }
        }

        var labelColor: Color {
            switch self {
            case .healthy: .textSuccess
            case .watch: .textCaution
            case .atRisk: .textWarning
            case .critical: .textDanger
            }
        }

        var background: Color {
            switch self {
            case .healthy: .tintSuccess
            case .watch: .tintCaution
            case .atRisk: .tintWarning
            case .critical: .tintDanger
            }
        }

        var border: Color {
            switch self {
            case .healthy: Color(red: 0xC5 / 255, green: 0xE8 / 255, blue: 0xCF / 255)
            case .watch: .lineTintCaution
            case .atRisk: .lineTintWarning
            case .critical: .lineTintDanger
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
