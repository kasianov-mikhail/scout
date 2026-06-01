//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

/// Which events the timeline shows: the originating event by name, or all events.
///
enum TimelineScope: CaseIterable, Identifiable {
    case event
    case all

    var id: Self { self }

    var title: String {
        switch self {
        case .event: "Event"
        case .all: "All"
        }
    }
}
