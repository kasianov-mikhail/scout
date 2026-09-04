//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout
@testable import ScoutUI

struct RetentionCohortRateTests {
    @Test("Reads the rate at a milestone")
    func milestone() {
        #expect(RetentionCohort.rate([1, 0.5, 0.4, 0.3, 0.2, 0.1], onDay: 7) == 0.3)
    }

    @Test("A day that is not a milestone has no rate")
    func nonMilestone() {
        #expect(RetentionCohort.rate([1, 0.5, 0.4, 0.3, 0.2, 0.1], onDay: 2) == nil)
    }

    @Test("A milestone the backend did not send reads as nil instead of trapping")
    func shortRetention() {
        #expect(RetentionCohort.rate([1, 0.5, 0.4, 0.3], onDay: 7) == 0.3)
        #expect(RetentionCohort.rate([1, 0.5, 0.4, 0.3], onDay: 30) == nil)
        #expect(RetentionCohort.rate([], onDay: 0) == nil)
    }

    @Test("Stats skip milestones no cohort reports")
    func statsTolerateShortRetention() {
        let week = Date(timeIntervalSince1970: 1_704_067_200).startOfWeek
        let cohorts = [
            RetentionCohort(id: week, size: 10, retention: [1, 0.5, 0.4, 0.3]),
            RetentionCohort(id: week.addingDay(7), size: 10, retention: [1, 0.7]),
        ]

        let stats = RetentionCohort.stats(for: cohorts)

        #expect(stats.map(\.day) == [0, 1, 3, 7])
        #expect(stats.first { $0.day == 1 }?.average == 0.6)
        #expect(stats.first { $0.day == 7 }?.average == 0.3)
    }
}
