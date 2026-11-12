//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension ActiveUsers {
    enum Kind: CaseIterable, Hashable, Identifiable {
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
                .fillSuccess
            case .sessions:
                .fillSession
            case .devices:
                .fillDevice
            }
        }
    }
}
