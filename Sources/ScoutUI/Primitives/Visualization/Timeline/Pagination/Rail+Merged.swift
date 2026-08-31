//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout

extension Rail {
    func merged(sessions: [Session], events: [Event]) -> Rail {
        let existing = flattened
        return Rail(
            device: device,
            installs: existing.installs,
            launches: existing.launches,
            sessions: dedup(new: sessions, old: existing.sessions),
            events: dedup(new: events, old: existing.events),
            crashes: existing.crashes
        )
    }
}

extension Rail {
    fileprivate typealias Flattened = (
        installs: [Install],
        launches: [Launch],
        sessions: [Session],
        events: [Event],
        crashes: [Crash]
    )

    fileprivate var flattened: Flattened {
        let launches = installs.flatMap(\.launches)
        let sessions = launches.flatMap(\.sessions)
        return (
            installs: installs.map(\.install),
            launches: launches.map(\.launch),
            sessions: sessions.map(\.session),
            events: sessions.flatMap(\.events),
            crashes: sessions.flatMap(\.crashes)
        )
    }
}
