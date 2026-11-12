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
            .fillDanger
        case .hang:
            .fillWarning
        case .resource:
            .fillResource
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
            .tintDanger
        case .hang:
            .tintWarning
        case .resource:
            .tintResource
        }
    }

    var border: Color {
        switch self {
        case .crash:
            .lineTintDanger
        case .hang:
            .lineTintWarning
        case .resource:
            .lineTintResource
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
