//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

extension Stability.Level {
    var surface: Color {
        switch self {
        case .healthy: Color(red: 0xE9 / 255, green: 0xF8 / 255, blue: 0xEE / 255)
        case .watch: Color(red: 0xFF / 255, green: 0xF8 / 255, blue: 0xDB / 255)
        case .atRisk: Color(red: 0xFF / 255, green: 0xF1 / 255, blue: 0xE0 / 255)
        case .critical: Color(red: 0xFF / 255, green: 0xEB / 255, blue: 0xEA / 255)
        }
    }

    var edge: Color {
        switch self {
        case .healthy: Color(red: 0xC5 / 255, green: 0xE8 / 255, blue: 0xCF / 255)
        case .watch: Color(red: 0xF0 / 255, green: 0xE2 / 255, blue: 0xA8 / 255)
        case .atRisk: Color(red: 0xF3 / 255, green: 0xD2 / 255, blue: 0xA9 / 255)
        case .critical: Color(red: 0xF3 / 255, green: 0xC1 / 255, blue: 0xBE / 255)
        }
    }

    var accent: Color {
        switch self {
        case .healthy: Color(red: 0x1E / 255, green: 0x7D / 255, blue: 0x34 / 255)
        case .watch: Color(red: 0x8A / 255, green: 0x6D / 255, blue: 0x00 / 255)
        case .atRisk: Color(red: 0xB3 / 255, green: 0x5C / 255, blue: 0x00 / 255)
        case .critical: Color(red: 0xC4 / 255, green: 0x00 / 255, blue: 0x1A / 255)
        }
    }
}
