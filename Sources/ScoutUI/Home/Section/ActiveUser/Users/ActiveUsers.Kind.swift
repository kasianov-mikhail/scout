//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension ActiveUsers {
    enum Kind: Hashable, Identifiable {
        case dau
        case sessions
        case devices

        var id: Self { self }

        var title: String {
            switch self {
            case .dau:
                "DAU"
            case .sessions:
                "Sessions"
            case .devices:
                "Devices"
            }
        }

        var accent: Color {
            switch self {
            case .dau:
                .green
            case .sessions:
                Color(red: 0x12 / 255, green: 0xA5 / 255, blue: 0x94 / 255)
            case .devices:
                Color(red: 0x5A / 255, green: 0xC8 / 255, blue: 0xFA / 255)
            }
        }
    }
}
