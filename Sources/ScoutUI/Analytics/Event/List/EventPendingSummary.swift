//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout

struct EventPendingSummary {
    struct Group {
        let level: EventLevel
        let count: Int
    }

    let total: Int
    let groups: [Group]

    init(events: [Event], limit: Int) {
        let counts = Dictionary(grouping: events.map { $0.level ?? .info }, by: \.self).mapValues(\.count)
        let sorted = counts.map { Group(level: $0.key, count: $0.value) }.sorted { $0.level > $1.level }

        total = events.count
        groups = Array(sorted.prefix(limit))
    }
}

extension EventPendingSummary {
    var isEmpty: Bool {
        total == 0
    }
}
