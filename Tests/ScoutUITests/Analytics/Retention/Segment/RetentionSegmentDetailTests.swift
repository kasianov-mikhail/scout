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
@testable import Support

struct RetentionSegmentDetailTests {
    private let now = Date(year: 2026, month: 11, day: 1)

    private let cohort = RetentionCohort(
        id: Date(year: 2026, month: 10, day: 13),
        size: 960,
        retention: [1, 0.43, 0.29, 0.2, nil, nil],
        segments: [
            RetentionSegment(name: "iOS 17", size: 680, retention: [1, 0.4, 0.3, 0.22, nil, nil], crashes: 6, hangs: 9),
            RetentionSegment(name: "iOS 16", size: 230, retention: [1, 0.36, 0.23, 0.16, nil, nil], crashes: 4, hangs: 7),
            RetentionSegment(name: "iOS 15", size: 50, retention: [1, 0.2, 0.15, 0.1, nil, nil], crashes: 2, hangs: 1),
        ]
    )

    private var detail: RetentionSegmentDetail {
        let older = RetentionCohort(
            id: Date(year: 2026, month: 10, day: 6),
            size: 1000,
            retention: [1, 0.4, 0.25, 0.1, 0.12, nil],
            segments: [RetentionSegment(name: "iOS 16", size: 240, retention: [1, 0.38, 0.22, 0.18, 0.12, nil], crashes: 0, hangs: 0)]
        )
        let second = RetentionCohort(
            id: Date(year: 2026, month: 9, day: 29),
            size: 900,
            retention: [1, 0.42, 0.27, 0.11, nil, nil],
            segments: [RetentionSegment(name: "iOS 16", size: 230, retention: [1, 0.37, 0.24, 0.19, nil, nil], crashes: 0, hangs: 0)]
        )
        let third = RetentionCohort(
            id: Date(year: 2026, month: 9, day: 22),
            size: 800,
            retention: [1, 0.39, 0.24, 0.09, nil, nil],
            segments: [RetentionSegment(name: "iOS 16", size: 250, retention: [1, 0.35, 0.21, 0.17, nil, nil], crashes: 0, hangs: 0)]
        )
        let without = RetentionCohort(
            id: Date(year: 2026, month: 9, day: 15),
            size: 700,
            retention: [1, 0.4, 0.25, 0.1, nil, nil],
            segments: [RetentionSegment(name: "iOS 17", size: 700, retention: [1, 0.4, 0.25, 0.1, nil, nil], crashes: 0, hangs: 0)]
        )
        let pending = RetentionCohort(
            id: Date(year: 2026, month: 10, day: 20),
            size: 950,
            retention: [1, 0.44, 0.3, nil, nil, nil],
            segments: [RetentionSegment(name: "iOS 16", size: 240, retention: [1, 0.4, 0.26, nil, nil, nil], crashes: 0, hangs: 0)]
        )

        let segment = cohort.segments[1]

        return RetentionSegmentDetail(segment: segment, cohort: cohort, cohorts: [pending, cohort, older, second, third, without], now: now)
    }

    @Test("The hero reads the installs, the OS and the week")
    func hero() {
        #expect(detail.installsLabel == "230")
        #expect(detail.subtitle == "installs on iOS 16 · Oct 13–19")
    }

    @Test("The day rows compare the segment with the whole week")
    func days() throws {
        let day = try #require(detail.days.first { $0.day == .day7 })

        #expect(day.rate == 0.16)
        #expect(day.kept == 37)
        #expect(day.average == 0.2)
    }

    @Test("A pending day points at the week average")
    func pending() throws {
        let day = try #require(detail.days.first { $0.day == .day14 })

        #expect(day.rate == nil)
        #expect(day.pendingLabel == "in 2 d")
        #expect(day.average == 0.12)
    }

    @Test("Stability reads the segment share and the whole week")
    func stability() {
        #expect(detail.crash.rateLabel == "1.7%")
        #expect(detail.crash.countLabel == "4 installs")
        #expect(detail.crash.subtitle == "Crashed · week 1.2%")

        #expect(detail.hang.rateLabel == "3.0%")
        #expect(detail.hang.countLabel == "7 installs")
        #expect(detail.hang.subtitle == "Hung · week 1.8%")
    }

    @Test("The week history keeps only weeks that matured day 7")
    func weeks() {
        #expect(
            detail.weeks.map(\.start) == [
                Date(year: 2026, month: 10, day: 13),
                Date(year: 2026, month: 10, day: 6),
                Date(year: 2026, month: 9, day: 29),
                Date(year: 2026, month: 9, day: 22),
            ])
    }

    @Test("The current week is the only green bar")
    func currentWeek() {
        #expect(detail.weeks.map(\.isCurrent) == [true, false, false, false])
    }

    @Test("The history rows read the kept count and the rate")
    func history() {
        #expect(detail.weeks.map(\.keptLabel) == ["37", "43", "44", "43"])
        #expect(detail.weeks.map(\.rateLabel) == ["16%", "18%", "19%", "17%"])
    }
}
