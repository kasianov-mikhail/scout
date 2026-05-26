//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

enum Rail: CaseIterable, Hashable {
    case install
    case launch
    case session
}

extension Rail {
    var label: String {
        switch self {
        case .install: "Install"
        case .launch: "Launch"
        case .session: "Session"
        }
    }

    var color: Color {
        switch self {
        case .install: .mint
        case .launch: .blue
        case .session: .green
        }
    }

    var legendDescription: String {
        switch self {
        case .install: "App installation lifetime"
        case .launch: "Current app launch"
        case .session: "Active user session"
        }
    }
}
