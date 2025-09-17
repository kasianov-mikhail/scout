//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension Telemetry {
    enum Visible: CaseIterable, Identifiable {
        case counter
        case floatingCounter
        case timer

        var id: Self { self }
    }
}

extension Telemetry.Visible {
    var title: String {
        switch self {
        case .counter:
            "Int Counter"
        case .floatingCounter:
            "Double Counter"
        case .timer:
            "Timer"
        }
    }

    var shortTitle: String {
        switch self {
        case .counter:
            "Int"
        case .floatingCounter:
            "Double"
        case .timer:
            "Timer"
        }
    }
}
