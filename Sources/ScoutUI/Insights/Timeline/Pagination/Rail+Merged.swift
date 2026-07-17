//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ScoutCore

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
        let installs = self.installs.map(\.install)
        let launches = self.installs.flatMap { $0.launches.map(\.launch) }
        let sessions = self.installs.flatMap { $0.launches.flatMap { $0.sessions.map(\.session) } }
        let events = self.installs.flatMap { $0.launches.flatMap { $0.sessions.flatMap(\.events) } }
        let crashes = self.installs.flatMap { $0.launches.flatMap { $0.sessions.flatMap(\.crashes) } }
        return (installs, launches, sessions, events, crashes)
    }
}
