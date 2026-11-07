//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct SessionTimeline {
    let info: SessionInfo
    let rows: [SessionTimelineRow]
}

struct SessionTimelineRow: Identifiable {
    enum Kind: Equatable {
        case start
        case event(Event)
        case screen(Screen)
        case crash(Crash)
        case hang(Hang)
        case resource(ResourceException)
        case gap
        case end(End)
    }

    enum End: Equatable {
        case background
        case crash
        case live
        case unknown
    }

    let id: String
    let kind: Kind
    let height: CGFloat
    let title: String
    let subtitle: String?
    let time: String?
}

extension SessionTimelineRow {
    var level: EventLevel? {
        guard case .event(let event) = kind else {
            return nil
        }
        switch event.level {
        case .warning, .error, .critical:
            return event.level
        default:
            return nil
        }
    }

    var incident: IncidentKind? {
        switch kind {
        case .crash:
            .crash
        case .hang:
            .hang
        case .resource:
            .resource
        default:
            nil
        }
    }
}
