//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension IncidentKind {
    var timelineColor: Color {
        switch self {
        case .crash:
            Color.timelineCrash
        case .hang:
            Color.timelineHang
        case .resource:
            Color.timelineResource
        }
    }

    var timelineInk: Color {
        switch self {
        case .crash:
            Color.timelineCrashInk
        case .hang:
            Color.timelineHangInk
        case .resource:
            Color.timelineResourceInk
        }
    }

    var timelineSymbol: String {
        switch self {
        case .crash:
            "exclamationmark"
        case .hang:
            "hourglass"
        case .resource:
            "speedometer"
        }
    }
}
