//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

enum GlobalSearchCategory: String, CaseIterable, Identifiable {
    case events
    case metrics
    case network
    case devices
    case releases
    case crashes
    case hangs

    var id: Self { self }

    var title: String {
        rawValue.capitalized
    }

    var color: Color {
        switch self {
        case .events:
            .blue
        case .metrics:
            .purple
        case .network:
            .teal
        case .devices:
            .cyan
        case .releases:
            .green
        case .crashes:
            .red
        case .hangs:
            .orange
        }
    }

    var isMonospaced: Bool {
        switch self {
        case .network, .crashes, .hangs:
            true
        default:
            false
        }
    }
}
