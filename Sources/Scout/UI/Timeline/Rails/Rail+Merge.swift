//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

extension DeviceRail {
    func merged(
        installs: [Install] = [],
        launches: [Launch] = [],
        sessions: [Session] = [],
        events: [Event] = [],
        crashes: [Crash] = []
    ) -> DeviceRail {
        let existing = flattened
        let trees = DeviceRail.tree(
            devices: [device],
            installs: dedup(new: installs, old: existing.installs),
            launches: dedup(new: launches, old: existing.launches),
            sessions: dedup(new: sessions, old: existing.sessions),
            events: dedup(new: events, old: existing.events),
            crashes: dedup(new: crashes, old: existing.crashes)
        )
        return trees.first ?? self
    }
}

extension DeviceRail {
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

private func dedup<T: Identifiable>(new: [T], old: [T]) -> [T] where T.ID == CKRecord.ID {
    var seen: Set<CKRecord.ID> = []
    var result: [T] = []
    result.reserveCapacity(new.count + old.count)
    for item in new where seen.insert(item.id).inserted {
        result.append(item)
    }
    for item in old where seen.insert(item.id).inserted {
        result.append(item)
    }
    return result
}
