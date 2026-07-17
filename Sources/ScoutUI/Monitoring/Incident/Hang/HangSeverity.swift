//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

enum HangSeverity {
    case warning
    case critical

    var label: String {
        switch self {
        case .warning:
            "Hang"
        case .critical:
            "Severe Hang"
        }
    }

    var color: Color {
        switch self {
        case .warning:
            .orange
        case .critical:
            .red
        }
    }

    var systemImage: String {
        switch self {
        case .warning:
            "hourglass"
        case .critical:
            "exclamationmark.octagon"
        }
    }
}
