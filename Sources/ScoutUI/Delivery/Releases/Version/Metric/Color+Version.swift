//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

extension Color {
    static let crashValue = Stability.Level.critical.accent
    static let hangValue = Stability.Level.atRisk.accent
    static let resourceValue = Color(red: 0x36 / 255, green: 0x34 / 255, blue: 0xA3 / 255)

    static let stabilityCritical = Color(red: 0xFF / 255, green: 0xE5 / 255, blue: 0xE5 / 255)
    static let stabilityWatch = Color(red: 0xFF / 255, green: 0xF3 / 255, blue: 0xD6 / 255)
    static let stabilityHealthy = Color(red: 0xE3 / 255, green: 0xF5 / 255, blue: 0xE8 / 255)
}
