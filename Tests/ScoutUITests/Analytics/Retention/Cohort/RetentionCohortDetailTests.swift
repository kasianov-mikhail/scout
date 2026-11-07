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

struct RetentionCohortDetailTests {
    private let now = Date(year: 2026, month: 11, day: 1)
    private let week = Date(year: 2026, month: 10, day: 13)
    private let previous = Date(year: 2026, month: 10, day: 6)
    private let pending = Date(year: 2026, month: 10, day: 27)

    private var cohort: RetentionCohort {
        RetentionCohort(
            id: week,
            size: 960,
            retention: [1, 0.43, 0.29, 0.2, nil, nil],
            segments: [
                RetentionSegment(name: "iOS 17", size: 680, retention: [1, 0.4, 0.3, 0.22, nil, nil], crashes: 6, hangs: 9),
                RetentionSegment(name: "iOS 16", size: 230, retention: [1, 0.36, 0.23, 0.16, nil, nil], crashes: 4, hangs: 7),
                RetentionSegment(name: "iOS 15", size: 50, retention: [1, 0.2, 0.15, 0.1, nil, nil], crashes: 2, hangs: 1),
            ]
        )
    }

    private var detail: RetentionCohortDetail {
        let older = RetentionCohort(id: previous, size: 1000, retention: [1, 0.4, 0.25, 0.1, nil, nil], segments: [])
        let open = RetentionCohort(id: pending, size: 900, retention: [1, 0.5, 0.35, nil, nil, nil], segments: [])

        return RetentionCohortDetail(cohort: cohort, cohorts: [open, older, cohort], now: now)
    }

    @Test("The hero reads the installs and the week")
    func hero() {
        #expect(detail.installsLabel == "960")
        #expect(detail.subtitle == "installs · Oct 13–19")
    }

    @Test("The week in progress stays out of the average")
    func averages() {
        #expect(detail.averages.count == 2)
        #expect(detail.averageNote == "average of 2 weeks")
    }

    @Test("Every day from 1 to 30 gets a row")
    func days() {
        #expect(detail.days.map(\.day) == [.day1, .day3, .day7, .day14, .day30])
    }

    @Test("A day reads the cohort rate and its kept count")
    func kept() throws {
        let day = try #require(detail.days.first { $0.day == .day7 })

        #expect(day.rate == 0.2)
        #expect(day.kept == 192)
        #expect(day.keptLabel == "192")
        #expect(day.rateLabel == "20%")
    }

    @Test("A day that has not matured reads as pending")
    func pendingWeek() throws {
        let day = try #require(detail.days.first { $0.day == .day14 })

        #expect(day.rate == nil)
        #expect(day.kept == nil)
        #expect(day.pendingLabel == "in 2 d")
    }

    @Test("The average weighs the completed weeks")
    func average() throws {
        let day = try #require(detail.days.first { $0.day == .day7 })

        #expect(abs((day.average ?? 0) - 0.1489) < 0.001)
    }

    @Test("The OS rows read day 7 and the crash share")
    func segments() throws {
        #expect(detail.segments.map(\.name) == ["iOS 17", "iOS 16", "iOS 15"])

        let latest = try #require(detail.segments.first)
        #expect(latest.installsLabel == "680 installs")
        #expect(latest.crashRateLabel == "0.9%")
        #expect(latest.kept == 150)
        #expect(latest.keptLabel == "150")
        #expect(latest.rateLabel == "22%")
    }

    @Test("Smaller OS shares keep their own rates")
    func smallSegments() {
        #expect(detail.segments.map(\.kept) == [150, 37, 5])
        #expect(detail.segments.map(\.rateLabel) == ["22%", "16%", "10%"])
        #expect(detail.segments.map(\.crashRateLabel) == ["0.9%", "1.7%", "4.0%"])
    }
}
