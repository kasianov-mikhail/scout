//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

extension Color {
    static let eventTimestamp = Color(red: 0x3C / 255, green: 0x3C / 255, blue: 0x43 / 255)
    static let eventContextLabel = Color(red: 0x6C / 255, green: 0x6C / 255, blue: 0x70 / 255)
    static let eventAboveUsual = Color(red: 0xE5 / 255, green: 0xB8 / 255, blue: 0)
}

extension EventLevel {
    var badgeInk: Color {
        switch self {
        case .warning:
            Color(red: 0x7A / 255, green: 0x5D / 255, blue: 0)
        case .error:
            Color(red: 0xB3 / 255, green: 0x5C / 255, blue: 0)
        case .critical:
            Color(red: 0xC4 / 255, green: 0, blue: 0x1A / 255)
        case .notice, .debug, .trace, .info:
            .secondary
        }
    }

    var badgeFill: Color {
        switch self {
        case .warning:
            Color(red: 1, green: 0xCC / 255, blue: 0).opacity(0.26)
        case .error:
            Color(red: 1, green: 0x95 / 255, blue: 0).opacity(0.2)
        case .critical:
            Color(red: 0xC4 / 255, green: 0, blue: 0x1A / 255).opacity(0.14)
        case .notice, .debug, .trace, .info:
            Color(.systemGray6)
        }
    }
}
