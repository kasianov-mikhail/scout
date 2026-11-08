//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import SwiftUI

extension Color {
    static let networkAccent = Color(red: 0x00 / 255, green: 0x7A / 255, blue: 0xFF / 255)
    static let networkTrack = Color(red: 0xD1 / 255, green: 0xD1 / 255, blue: 0xD6 / 255)
    static let networkWarning = Color(red: 0xB3 / 255, green: 0x5C / 255, blue: 0x00 / 255)
    static let networkCritical = Color(red: 0xC4 / 255, green: 0x00 / 255, blue: 0x1A / 255)
    static let networkSlow = Color(red: 0xFF / 255, green: 0xB3 / 255, blue: 0x40 / 255)
    static let networkClient = Color(red: 0xFF / 255, green: 0x95 / 255, blue: 0x00 / 255)
    static let networkServer = Color(red: 0xFF / 255, green: 0x3B / 255, blue: 0x30 / 255)
    static let networkRedirect = Color(red: 0x00 / 255, green: 0x7A / 255, blue: 0xFF / 255)
    static let networkGet = Color(red: 0x1E / 255, green: 0x7D / 255, blue: 0x34 / 255)
    static let networkPost = Color(red: 0x00 / 255, green: 0x62 / 255, blue: 0xCC / 255)
    static let networkPut = Color(red: 0xB3 / 255, green: 0x5C / 255, blue: 0x00 / 255)
    static let networkDelete = Color(red: 0xC4 / 255, green: 0x00 / 255, blue: 0x1A / 255)
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
            .primary
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
        map(\.networkColor) ?? Color(.systemGray)
    }
}

extension TimeInterval {
    var networkP99Color: Color {
        self >= 1 ? .networkWarning : .primary
    }

    var networkP99Weight: Font.Weight {
        self >= 1 ? .bold : .regular
    }
}

extension Optional where Wrapped == TimeInterval {
    var networkP99Value: String {
        map(\.duration) ?? "—"
    }

    var networkP99Color: Color {
        map(\.networkP99Color) ?? Color(.systemGray)
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
