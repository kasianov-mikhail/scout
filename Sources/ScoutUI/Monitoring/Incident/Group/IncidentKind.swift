//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

enum IncidentKind: CaseIterable, Sendable {
    case crash
    case hang
    case resource
}

extension IncidentKind {
    var title: String {
        switch self {
        case .crash:
            "Crashes"
        case .hang:
            "Hangs"
        case .resource:
            "Resource exceptions"
        }
    }

    var color: Color {
        switch self {
        case .crash:
            .red
        case .hang:
            .orange
        case .resource:
            .indigo
        }
    }

    var labelColor: Color {
        switch self {
        case .crash:
            Color(red: 196 / 255, green: 0, blue: 26 / 255)
        case .hang:
            Color(red: 179 / 255, green: 92 / 255, blue: 0)
        case .resource:
            Color(red: 54 / 255, green: 52 / 255, blue: 163 / 255)
        }
    }

    var noun: String {
        switch self {
        case .crash:
            "crash"
        case .hang:
            "hang"
        case .resource:
            "report"
        }
    }

    var pluralNoun: String {
        switch self {
        case .crash:
            "crashes"
        case .hang:
            "hangs"
        case .resource:
            "reports"
        }
    }

    var captionName: String {
        switch self {
        case .crash:
            "red"
        case .hang:
            "orange"
        case .resource:
            "indigo"
        }
    }
}
