//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

@MainActor
struct TimelineRows {
    let entries: [TimelineEntry]

    init(rail: Rail, incidents: TimelineIncidents, focus: TimelineFocus?, now: Date, reachesStart: Bool, reachesEnd: Bool) {
        var builder = TimelineRowsBuilder(
            rail: rail,
            incidents: incidents,
            focus: focus,
            now: now,
            reachesStart: reachesStart,
            reachesEnd: reachesEnd
        )
        entries = builder.build()
    }
}
