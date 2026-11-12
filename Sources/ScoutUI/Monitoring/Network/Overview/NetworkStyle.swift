//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import SwiftUI

extension Color {
    static let networkAccent = fillAccent
    static let networkTrack = surfaceBarIdle
    static let networkWarning = textWarning
    static let networkCritical = textDanger
    static let networkSlow = Color(red: 0xFF / 255, green: 0xB3 / 255, blue: 0x40 / 255)
    static let networkClient = fillWarning
    static let networkServer = fillDanger
    static let networkRedirect = fillAccent
    static let networkGet = textSuccess
    static let networkPost = Color(red: 0x00 / 255, green: 0x62 / 255, blue: 0xCC / 255)
    static let networkPut = textWarning
    static let networkDelete = textDanger
}

extension Stability {
    var networkValue: String {
        String(format: "%.1f", value * 100)
    }

    var networkPercent: String {
        networkValue + "%"
    }

    var networkColor: Color {
        switch value {
        case 0.985...:
            .textPrimary
        case 0.95..<0.985:
            .networkWarning
        default:
            .networkCritical
        }
    }
}

extension Optional where Wrapped == Stability {
    var networkValue: String {
        map(\.networkValue) ?? "—"
    }

    var networkColor: Color {
        map(\.networkColor) ?? .textMuted
    }
}

extension TimeInterval {
    var networkP99Color: Color {
        self >= 1 ? .networkWarning : .textPrimary
    }

    var networkP99Weight: Font.Weight {
        self >= 1 ? .semibold : .regular
    }
}

extension Optional where Wrapped == TimeInterval {
    var networkP99Value: String {
        map(\.duration) ?? "—"
    }

    var networkP99Color: Color {
        map(\.networkP99Color) ?? .textMuted
    }

    var networkP99Weight: Font.Weight {
        map(\.networkP99Weight) ?? .regular
    }
}

extension Int {
    var networkCount: String {
        self < 10_000 ? formatted(.number.locale(Locale(identifier: "en_US"))) : compact
    }
}

extension Calendar.Component {
    var networkTitle: String {
        switch self {
        case .hour:
            "HOUR"
        case .day:
            "DAY"
        case .month:
            "MONTH"
        default:
            "ROW"
        }
    }
}

extension DateFormatter {
    static let networkHourLabel = DateFormatter(format: "HH:mm")
    static let networkDayLabel = DateFormatter(format: "EEE d")
    static let networkMonthLabel = DateFormatter(format: "MMM")
    static let networkMonthDayLabel = DateFormatter(format: "MMM d")
    static let networkDayFull = DateFormatter(format: "EEE, MMM d")
    static let networkMonthFull = DateFormatter(format: "MMMM")
}
