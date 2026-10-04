//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout
@testable import Support

struct RetentionCohortBuildTests {
    private let installDay = Date(year: 2026, month: 6, day: 1)
    private let range = Date(year: 2026, month: 5, day: 1)..<Date(year: 2026, month: 8, day: 1)
    private let now = Date(year: 2026, month: 8, day: 1)

    @Test("Bounded day-N retention counts activity on exactly install day + N")
    func boundedDayNRates() throws {
        let cohorts = [RetentionCohort](
            installs: [DatedID(date: installDay, id: "a"), DatedID(date: installDay, id: "b")],
            sessions: [InstallSession(install: "a", date: installDay, os: nil), InstallSession(install: "a", date: installDay.addingDay(), os: nil), InstallSession(install: "a", date: installDay.addingDay(7), os: nil), InstallSession(install: "b", date: installDay, os: nil)],
            crashes: [],
            hangs: [],
            range: range,
            now: now
        )

        let cohort = try #require(cohorts.first { $0.id == installDay.startOfWeek })

        #expect(cohort.size == 2)
        #expect(RetentionCohort.rate(cohort.retention, onDay: 0) == 1)
        #expect(RetentionCohort.rate(cohort.retention, onDay: 1) == 0.5)
        #expect(RetentionCohort.rate(cohort.retention, onDay: 3) == 0)
        #expect(RetentionCohort.rate(cohort.retention, onDay: 7) == 0.5)
        #expect(RetentionCohort.rate(cohort.retention, onDay: 30) == 0)
    }

    @Test("An install with no return activity still counts in the cohort size")
    func inactiveInstallCountsInSize() throws {
        let cohorts = [RetentionCohort](
            installs: [DatedID(date: installDay, id: "a"), DatedID(date: installDay, id: "b")],
            sessions: [InstallSession(install: "a", date: installDay, os: nil)],
            crashes: [],
            hangs: [],
            range: range,
            now: now
        )

        let cohort = try #require(cohorts.first { $0.id == installDay.startOfWeek })

        #expect(cohort.size == 2)
        #expect(RetentionCohort.rate(cohort.retention, onDay: 0) == 0.5)
    }

    @Test("Milestones that have not elapsed by the cutoff are nil")
    func immatureMilestonesAreNil() throws {
        let recentInstall = Date(year: 2026, month: 7, day: 20)

        let cohorts = [RetentionCohort](
            installs: [DatedID(date: recentInstall, id: "a")],
            sessions: [InstallSession(install: "a", date: recentInstall, os: nil)],
            crashes: [],
            hangs: [],
            range: Date(year: 2026, month: 7, day: 1)..<Date(year: 2026, month: 8, day: 1),
            now: now
        )

        let cohort = try #require(cohorts.first { $0.id == recentInstall.startOfWeek })

        #expect(RetentionCohort.rate(cohort.retention, onDay: 0) == 1)
        #expect(RetentionCohort.rate(cohort.retention, onDay: 30) == nil)
    }

    @Test("A milestone stays nil until the full cohort week plus the offset has elapsed")
    func maturityRequiresTheFullCohortWeek() throws {
        let week = installDay.startOfWeek

        func dayZero(now: Date) throws -> Double? {
            let cohorts = [RetentionCohort](
                installs: [DatedID(date: installDay, id: "a")],
                sessions: [InstallSession(install: "a", date: installDay, os: nil)],
                crashes: [],
                hangs: [],
                range: week..<week.addingDay(7),
                now: now
            )
            let cohort = try #require(cohorts.first { $0.id == week })
            return RetentionCohort.rate(cohort.retention, onDay: 0)
        }

        // The cohort week spans week+0..week+6 and only fully elapses at week+7.
        #expect(try dayZero(now: week.addingDay(7)) == nil)
        #expect(try dayZero(now: week.addingDay(7).addingTimeInterval(1)) == 1)
    }

    @Test("Segments split the cohort by the OS version of each install")
    func segmentsSplitByOSVersion() throws {
        let cohorts = [RetentionCohort](
            installs: [DatedID(date: installDay, id: "a"), DatedID(date: installDay, id: "b"), DatedID(date: installDay, id: "c")],
            sessions: [
                InstallSession(install: "a", date: installDay, os: "iOS 18"), InstallSession(install: "a", date: installDay.addingDay(7), os: "iOS 18"),
                InstallSession(install: "b", date: installDay, os: "iOS 18"),
                InstallSession(install: "c", date: installDay, os: "iOS 17"), InstallSession(install: "c", date: installDay.addingDay(7), os: "iOS 17"),
            ],
            crashes: [],
            hangs: [],
            range: range,
            now: now
        )

        let cohort = try #require(cohorts.first { $0.id == installDay.startOfWeek })

        #expect(cohort.segments.map(\.name) == ["iOS 18", "iOS 17"])
        #expect(cohort.segments.map(\.size) == [2, 1])

        let latest = try #require(cohort.segments.first)
        #expect(RetentionCohort.rate(latest.retention, onDay: 0) == 1)
        #expect(RetentionCohort.rate(latest.retention, onDay: 7) == 0.5)

        let older = try #require(cohort.segments.last)
        #expect(RetentionCohort.rate(older.retention, onDay: 7) == 1)
    }

    @Test("An install's OS is the one its earliest session reported")
    func osVersionComesFromTheEarliestSession() throws {
        let cohorts = [RetentionCohort](
            installs: [DatedID(date: installDay, id: "a"), DatedID(date: installDay, id: "b")],
            sessions: [
                InstallSession(install: "a", date: installDay.addingDay(7), os: "iOS 18.1"), InstallSession(install: "a", date: installDay, os: "iOS 17.5"),
                InstallSession(install: "b", date: installDay, os: nil), InstallSession(install: "b", date: installDay.addingDay(3), os: "iOS 18.0"),
            ],
            crashes: [],
            hangs: [],
            range: range,
            now: now
        )

        let cohort = try #require(cohorts.first { $0.id == installDay.startOfWeek })

        #expect(cohort.segments.map(\.name) == ["iOS 18", "iOS 17"])
    }

    @Test("OS versions bucket into their major version, keeping the platform name")
    func osVersionsBucketByMajor() throws {
        let cohorts = [RetentionCohort](
            installs: [DatedID(date: installDay, id: "a"), DatedID(date: installDay, id: "b"), DatedID(date: installDay, id: "c")],
            sessions: [InstallSession(install: "a", date: installDay, os: "iOS 18.1"), InstallSession(install: "b", date: installDay, os: "iOS 18.0"), InstallSession(install: "c", date: installDay, os: "iPadOS 17.5.1")],
            crashes: [],
            hangs: [],
            range: range,
            now: now
        )

        let cohort = try #require(cohorts.first { $0.id == installDay.startOfWeek })

        #expect(cohort.segments.map(\.name) == ["iOS 18", "iPadOS 17"])
        #expect(cohort.segments.map(\.size) == [2, 1])
    }

    @Test("Equal-sized segments order the newer version first")
    func tiesOrderNumerically() throws {
        let cohorts = [RetentionCohort](
            installs: [DatedID(date: installDay, id: "a"), DatedID(date: installDay, id: "b")],
            sessions: [InstallSession(install: "a", date: installDay, os: "iOS 9.3"), InstallSession(install: "b", date: installDay, os: "iOS 18.1")],
            crashes: [],
            hangs: [],
            range: range,
            now: now
        )

        let cohort = try #require(cohorts.first { $0.id == installDay.startOfWeek })

        #expect(cohort.segments.map(\.name) == ["iOS 18", "iOS 9"])
    }

    @Test("Crash and hang shares count the installs of the segment that saw them")
    func segmentIncidentShares() throws {
        let cohorts = [RetentionCohort](
            installs: [DatedID(date: installDay, id: "a"), DatedID(date: installDay, id: "b"), DatedID(date: installDay, id: "c")],
            sessions: [InstallSession(install: "a", date: installDay, os: "iOS 18"), InstallSession(install: "b", date: installDay, os: "iOS 18"), InstallSession(install: "c", date: installDay, os: "iOS 17")],
            crashes: [DatedID(date: installDay, id: "a")],
            hangs: [DatedID(date: installDay, id: "a"), DatedID(date: installDay.addingDay(30), id: "c")],
            range: range,
            now: now
        )

        let cohort = try #require(cohorts.first { $0.id == installDay.startOfWeek })

        let latest = try #require(cohort.segments.first)
        #expect(latest.crashes == 1)
        #expect(latest.hangs == 1)

        let older = try #require(cohort.segments.last)
        #expect(older.crashes == 0)
    }

    @Test("Incidents count only inside the milestone horizon after the install")
    func incidentsBeyondHorizonIgnored() throws {
        let cohorts = [RetentionCohort](
            installs: [DatedID(date: installDay, id: "a"), DatedID(date: installDay, id: "b")],
            sessions: [InstallSession(install: "a", date: installDay, os: "iOS 18"), InstallSession(install: "b", date: installDay, os: "iOS 18")],
            crashes: [DatedID(date: installDay.addingDay(31), id: "a"), DatedID(date: installDay.addingDay(30), id: "b")],
            hangs: [],
            range: range,
            now: now
        )

        let segment = try #require(cohorts.first?.segments.first)

        #expect(segment.crashes == 1)
    }

    @Test("An incident on an install outside the range counts nowhere")
    func incidentsOutsideRangeIgnored() throws {
        let cohorts = [RetentionCohort](
            installs: [DatedID(date: installDay, id: "a")],
            sessions: [InstallSession(install: "a", date: installDay, os: "iOS 18")],
            crashes: [DatedID(date: installDay, id: "stranger")],
            hangs: [],
            range: range,
            now: now
        )

        let segment = try #require(cohorts.first?.segments.first)

        #expect(segment.crashes == 0)
    }

    @Test("An install with no OS version counts in the cohort but in no segment")
    func installWithoutOSVersionIsUnsegmented() throws {
        let cohorts = [RetentionCohort](
            installs: [DatedID(date: installDay, id: "a"), DatedID(date: installDay, id: "b")],
            sessions: [InstallSession(install: "a", date: installDay, os: "iOS 18"), InstallSession(install: "b", date: installDay, os: nil)],
            crashes: [],
            hangs: [],
            range: range,
            now: now
        )

        let cohort = try #require(cohorts.first { $0.id == installDay.startOfWeek })

        #expect(cohort.size == 2)
        #expect(cohort.segments.map(\.size) == [1])
    }

    @Test("Without OS versions a cohort has no segments")
    func noSegmentsWithoutOSVersions() throws {
        let cohorts = [RetentionCohort](
            installs: [DatedID(date: installDay, id: "a")],
            sessions: [InstallSession(install: "a", date: installDay, os: nil)],
            crashes: [],
            hangs: [],
            range: range,
            now: now
        )

        let cohort = try #require(cohorts.first { $0.id == installDay.startOfWeek })

        #expect(cohort.segments.count == 0)
    }

    @Test("Milestones that have not elapsed are nil in segments too")
    func immatureSegmentMilestonesAreNil() throws {
        let recentInstall = Date(year: 2026, month: 7, day: 20)

        let cohorts = [RetentionCohort](
            installs: [DatedID(date: recentInstall, id: "a")],
            sessions: [InstallSession(install: "a", date: recentInstall, os: "iOS 18")],
            crashes: [],
            hangs: [],
            range: Date(year: 2026, month: 7, day: 1)..<Date(year: 2026, month: 8, day: 1),
            now: now
        )

        let cohort = try #require(cohorts.first { $0.id == recentInstall.startOfWeek })
        let segment = try #require(cohort.segments.first)

        #expect(RetentionCohort.rate(segment.retention, onDay: 0) == 1)
        #expect(RetentionCohort.rate(segment.retention, onDay: 30) == nil)
    }

    @Test("Installs outside the range are excluded")
    func installsOutsideRangeExcluded() {
        let cohorts = [RetentionCohort](
            installs: [DatedID(date: Date(year: 2026, month: 1, day: 1), id: "a")],
            sessions: [InstallSession(install: "a", date: Date(year: 2026, month: 1, day: 1), os: nil)],
            crashes: [],
            hangs: [],
            range: range,
            now: now
        )

        #expect(cohorts.count == 0)
    }
}
