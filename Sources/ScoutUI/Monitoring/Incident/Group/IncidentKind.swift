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

    var textColor: Color {
        switch self {
        case .crash:
            .crashText
        case .hang:
            .hangText
        case .resource:
            .resourceText
        }
    }

    var background: Color {
        switch self {
        case .crash:
            Color(red: 0xFD / 255, green: 0xEE / 255, blue: 0xEE / 255)
        case .hang:
            Color(red: 0xFF / 255, green: 0xF4 / 255, blue: 0xE5 / 255)
        case .resource:
            Color(red: 0xEF / 255, green: 0xEF / 255, blue: 0xFC / 255)
        }
    }

    var border: Color {
        switch self {
        case .crash:
            Color(red: 0xEE / 255, green: 0xD5 / 255, blue: 0xD5 / 255)
        case .hang:
            Color(red: 0xF2 / 255, green: 0xDF / 255, blue: 0xC4 / 255)
        case .resource:
            Color(red: 0xDA / 255, green: 0xDA / 255, blue: 0xF2 / 255)
        }
    }

    var stackCaption: String {
        switch self {
        case .crash:
            "Latest occurrence"
        case .hang:
            "Longest occurrence"
        case .resource:
            "Heaviest report"
        }
    }

    var occurrencesTitle: String {
        switch self {
        case .crash, .hang:
            "OCCURRENCES"
        case .resource:
            "REPORTS"
        }
    }
}
