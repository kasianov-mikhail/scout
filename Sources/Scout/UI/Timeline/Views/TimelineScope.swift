//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

/// Which events the timeline shows: the originating event by name, or all events.
///
enum TimelineScope {
    case event, all

    var title: String {
        switch self {
        case .event: "Event"
        case .all: "All"
        }
    }

    mutating func toggle() {
        self = self == .event ? .all : .event
    }
}
