//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct TimelineEntry: Identifiable {
    enum Kind: Equatable {
        case install
        case launch
        case close
        case unknown
        case fork
        case merge
        case loop
        case gap
        case event
        case crash
        case hang
        case resource
    }

    enum Marker {
        case milestone(symbol: String, color: Color)
        case event
        case incident(IncidentKind)
    }

    enum Connector {
        case fork
        case merge(color: Color, dashed: Bool)
        case loop(color: Color)
    }

    struct Lane {
        struct Split {
            let color: Color
            let y: CGFloat
        }

        let color: Color
        let dashed: Bool
        let top: CGFloat
        let bottom: CGFloat
        var split: Split? = nil
    }

    struct Label {
        let text: String
        let size: CGFloat
        let weight: Font.Weight
        let color: Color
        var italic = false
        var monospaced = false
    }

    let id: String
    let kind: Kind
    let height: CGFloat
    let launch: Lane?
    let session: Lane?
    let connector: Connector?
    let marker: Marker?
    let title: Label
    let subtitle: Label?
    let time: String?
    let chip: String?
    let tint: Color?
    var showsSeparator = false
}

extension TimelineEntry.Kind {
    var isItem: Bool {
        switch self {
        case .event, .crash, .hang, .resource:
            true
        default:
            false
        }
    }

    var incident: IncidentKind? {
        switch self {
        case .crash:
            IncidentKind.crash
        case .hang:
            IncidentKind.hang
        case .resource:
            IncidentKind.resource
        default:
            nil
        }
    }
}

extension TimelineEntry {
    var isFocused: Bool {
        tint != nil
    }
}
