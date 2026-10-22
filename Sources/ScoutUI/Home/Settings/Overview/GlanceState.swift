//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

enum GlanceState {
    case empty
    case checking
    case operational
    case degraded

    var color: Color {
        switch self {
        case .empty, .checking:
            .gray
        case .operational:
            .green
        case .degraded:
            .orange
        }
    }

    var icon: String {
        switch self {
        case .empty:
            "server.rack"
        case .checking:
            "arrow.triangle.2.circlepath"
        case .operational:
            "checkmark.seal.fill"
        case .degraded:
            "exclamationmark.triangle.fill"
        }
    }
}
