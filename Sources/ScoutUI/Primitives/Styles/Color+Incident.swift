//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

extension Color {
    static let crashText = Color(red: 0xC4 / 255, green: 0x00 / 255, blue: 0x1A / 255)
    static let hangText = Color(red: 0xB3 / 255, green: 0x5C / 255, blue: 0x00 / 255)
    static let resourceText = Color(red: 0x36 / 255, green: 0x34 / 255, blue: 0xA3 / 255)
}

extension IncidentKind {
    var detailColor: Color {
        switch self {
        case .crash:
            .crashText
        case .hang:
            .hangText
        case .resource:
            .resourceText
        }
    }

    var detailBackground: Color {
        switch self {
        case .crash:
            Color(red: 0xFD / 255, green: 0xEE / 255, blue: 0xEE / 255)
        case .hang:
            Color(red: 0xFF / 255, green: 0xF4 / 255, blue: 0xE5 / 255)
        case .resource:
            Color(red: 0xEF / 255, green: 0xEF / 255, blue: 0xFC / 255)
        }
    }
}
