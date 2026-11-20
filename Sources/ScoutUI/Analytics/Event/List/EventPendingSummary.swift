//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Scout

struct EventPendingSummary: Equatable {
    struct Group: Equatable {
        let level: EventLevel
        let count: Int
    }

    let total: Int
    let groups: [Group]

    static let empty = EventPendingSummary(counts: [:], limit: 0)

    init(counts: [EventLevel: Int], limit: Int) {
        total = counts.values.reduce(0, +)
        groups = Array(
            counts
                .map { Group(level: $0.key, count: $0.value) }
                .sorted { $0.level > $1.level }
                .prefix(limit)
        )
    }
}

extension EventPendingSummary {
    var isEmpty: Bool {
        total == 0
    }
}
