//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

extension Color {
    static let eventTimestamp = textSecondary
    static let eventContextLabel = textSecondary
    static let eventAboveUsual = Color(red: 0xE5 / 255, green: 0xB8 / 255, blue: 0)
}

extension EventLevel {
    var badgeInk: Color {
        switch self {
        case .warning:
            .textCaution
        case .error:
            .textWarning
        case .critical:
            .textDanger
        case .notice, .debug, .trace, .info:
            .textSecondary
        }
    }

    var badgeFill: Color {
        switch self {
        case .warning:
            .tintCaution
        case .error:
            .tintWarning
        case .critical:
            .tintDanger
        case .notice, .debug, .trace, .info:
            .surfaceGrey
        }
    }
}
