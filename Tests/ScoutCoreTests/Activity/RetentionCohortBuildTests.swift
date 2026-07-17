//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import ScoutCore
@testable import ScoutTestSupport

struct RetentionCohortBuildTests {
    private let installDay = Date(year: 2026, month: 6, day: 1)

    private func rate(_ cohort: RetentionCohort, day: Int) -> Double? {
        guard let index = RetentionCohort.dayOffsets.firstIndex(of: day) else {
            return nil
        }
        return cohort.retention[index]
    }

    @Test("Bounded day-N retention counts activity on exactly install day + N")
    func boundedDayNRates() throws {
        let cohorts = RetentionCohort.build(
            installDays: ["a": installDay, "b": installDay],
            sessionDays: [
                // Install "a" returns on D0, D1, D7.
                "a": [installDay, installDay.addingDay(), installDay.addingDay(7)],
                // Install "b" only opens on D0.
                "b": [installDay],
            ],
            in: Date(year: 2026, month: 5, day: 1)..<Date(year: 2026, month: 8, day: 1),
            asOf: Date(year: 2026, month: 8, day: 1)
        )

        let cohort = try #require(cohorts.first { $0.id == installDay.startOfWeek })

        #expect(cohort.size == 2)
        #expect(rate(cohort, day: 0) == 1)
        #expect(rate(cohort, day: 1) == 0.5)
        #expect(rate(cohort, day: 3) == 0)
        #expect(rate(cohort, day: 7) == 0.5)
        #expect(rate(cohort, day: 30) == 0)
    }

    @Test("An install with no return activity still counts in the cohort size")
    func inactiveInstallCountsInSize() throws {
        let cohorts = RetentionCohort.build(
            installDays: ["a": installDay, "b": installDay],
            sessionDays: ["a": [installDay]],
            in: Date(year: 2026, month: 5, day: 1)..<Date(year: 2026, month: 8, day: 1),
            asOf: Date(year: 2026, month: 8, day: 1)
        )

        let cohort = try #require(cohorts.first { $0.id == installDay.startOfWeek })

        #expect(cohort.size == 2)
        #expect(rate(cohort, day: 0) == 0.5)
    }

    @Test("Milestones that have not elapsed by the cutoff are nil")
    func immatureMilestonesAreNil() throws {
        let recentInstall = Date(year: 2026, month: 7, day: 20)

        let cohorts = RetentionCohort.build(
            installDays: ["a": recentInstall],
            sessionDays: ["a": [recentInstall]],
            in: Date(year: 2026, month: 7, day: 1)..<Date(year: 2026, month: 8, day: 1),
            asOf: Date(year: 2026, month: 8, day: 1)
        )

        let cohort = try #require(cohorts.first { $0.id == recentInstall.startOfWeek })

        #expect(rate(cohort, day: 0) == 1)
        #expect(rate(cohort, day: 30) == nil)
    }

    @Test("Installs outside the range are excluded")
    func installsOutsideRangeExcluded() {
        let cohorts = RetentionCohort.build(
            installDays: ["a": Date(year: 2026, month: 1, day: 1)],
            sessionDays: ["a": [Date(year: 2026, month: 1, day: 1)]],
            in: Date(year: 2026, month: 5, day: 1)..<Date(year: 2026, month: 8, day: 1),
            asOf: Date(year: 2026, month: 8, day: 1)
        )

        #expect(cohorts.count == 0)
    }
}
