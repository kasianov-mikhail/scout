//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import Testing

@testable import ScoutUI

struct RetentionWeekLiveTests {
    @Test("Cohorts map to the four newest weeks")
    func cohorts() {
        let weeks = [RetentionWeek](cohorts: [RetentionCohort].samples)

        #expect(weeks.count == 4)
        #expect(weeks.map(\.start) == weeks.map(\.start).sorted(by: >))
    }

    @Test("Kept is the day-7 rate of the cohort size")
    func kept() throws {
        let cohort = RetentionCohort(
            id: Date().startOfDay.addingDay(-10),
            size: 1000,
            retention: [1, 0.5, 0.3, 0.2, 0.1, 0.05],
            segments: []
        )
        let week = try #require([RetentionWeek](cohorts: [cohort]).first)

        #expect(week.installs == 1000)
        #expect(week.kept == 200)
    }

    @Test("A cohort without day 7 stays pending")
    func pending() throws {
        let cohort = RetentionCohort(
            id: Date().startOfDay.addingDay(-2),
            size: 1000,
            retention: [1, 0.5, 0.3, nil, nil, nil],
            segments: []
        )
        let week = try #require([RetentionWeek](cohorts: [cohort]).first)

        #expect(week.kept == nil)
        #expect(week.rate == nil)
        #expect(week.pendingLabel == "in 12 d")
    }
}
