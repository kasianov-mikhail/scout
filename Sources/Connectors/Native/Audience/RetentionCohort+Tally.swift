//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension [RetentionCohort] {
    init(tallies: [RetentionTally], now: Date) {
        self = Dictionary(grouping: tallies, by: \.week)
            .compactMap { week, tallies in
                RetentionCohort(week: week, tallies: tallies, now: now)
            }
            .sorted()
    }
}

extension RetentionCohort {
    fileprivate init?(week: Date, tallies: [RetentionTally], now: Date) {
        let counts = MilestoneCounts(tallies: tallies)

        guard counts[.install] > 0 else {
            return nil
        }

        let segments = Dictionary(grouping: tallies, by: \.system).compactMap { system, tallies in
            system.flatMap { RetentionSegment(name: $0, week: week, tallies: tallies, now: now) }
        }

        self.init(
            id: week,
            size: counts[.install],
            retention: counts.retention(week: week, now: now),
            segments: segments.sorted()
        )
    }
}

extension RetentionSegment {
    fileprivate init?(name: String, week: Date, tallies: [RetentionTally], now: Date) {
        let counts = MilestoneCounts(tallies: tallies)

        guard counts[.install] > 0 else {
            return nil
        }

        self.init(
            name: name,
            size: counts[.install],
            retention: counts.retention(week: week, now: now),
            crashes: counts[.crash],
            hangs: counts[.hang]
        )
    }
}

private struct MilestoneCounts {
    let counts: [RetentionMilestone: Int]

    init(tallies: [RetentionTally]) {
        counts = tallies.reduce(into: [:]) { counts, tally in
            counts[tally.milestone, default: 0] += tally.count
        }
    }

    subscript(milestone: RetentionMilestone) -> Int {
        counts[milestone, default: 0]
    }

    func retention(week: Date, now: Date) -> [Double?] {
        RetentionCohort.dayOffsets.map { offset in
            guard week.addingDay(7 + offset) < now else {
                return nil
            }
            return Double(self[.day(offset)]) / Double(self[.install])
        }
    }
}
