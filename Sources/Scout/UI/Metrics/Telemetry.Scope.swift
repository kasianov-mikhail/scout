//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension Telemetry {
    enum Scope: CaseIterable, Identifiable {
        case counter
        case floatingCounter
        case timer

        var id: Self { self }

        init?(export: Export) {
            switch export {
            case .counter:
                self = .counter
            case .floatingCounter:
                self = .floatingCounter
            case .timer:
                self = .timer
            default:
                return nil
            }
        }

        var export: Export {
            switch self {
            case .counter:
                .counter
            case .floatingCounter:
                .floatingCounter
            case .timer:
                .timer
            }
        }
    }
}

extension Telemetry.Scope {
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
