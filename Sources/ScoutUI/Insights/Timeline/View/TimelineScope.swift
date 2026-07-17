//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ScoutCore

/// Which events the timeline shows: the originating event by name, or all events.
///
enum TimelineScope: CaseIterable, Identifiable {
    case all
    case event

    var id: Self { self }

    var title: String {
        switch self {
        case .all:
            "All"
        case .event:
            "Event"
        }
    }
}
