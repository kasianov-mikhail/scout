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

struct RetentionOverviewTests {
    private let now = Date(year: 2026, month: 11, day: 1)

    private func cohorts(day7: [Double?]) -> [RetentionCohort] {
        day7.enumerated().map { index, rate in
            RetentionCohort(
                id: now.addingDay(-7 * index),
                size: 100 + index * 10,
                retention: [1, 0.4, 0.3, rate, nil, nil],
                segments: []
            )
        }
    }

    @Test("Keeps the eight newest weeks and the eight before them")
    func windows() {
        let overview = RetentionOverview(cohorts: cohorts(day7: [Double?](repeating: 0.2, count: 20)))

        #expect(overview.weeks.count == 8)
        #expect(overview.weeks.first?.id == now)
        #expect(overview.weeks.last?.id == now.addingDay(-49))
        #expect(overview.previousWeeks.count == 8)
        #expect(overview.previousWeeks.first?.id == now.addingDay(-56))
    }

    @Test("The hero counts the people kept on the selected day")
    func kept() {
        let overview = RetentionOverview(cohorts: cohorts(day7: [Double?](repeating: 0.2, count: 8)))

        #expect(overview.kept(day: .day7) == 216)
        #expect(overview.keptLabel(day: .day7) == "216")
    }

    @Test("The average weighs weeks by their installs")
    func average() {
        let overview = RetentionOverview(cohorts: cohorts(day7: [Double?](repeating: 0.2, count: 8)))

        #expect(abs((overview.average(day: .day7) ?? 0) - 0.2) < 0.0001)
        #expect(overview.metric(day: .day7).rateLabel == "20%")
    }

    @Test("The delta compares the two eight-week windows in points")
    func delta() {
        let rates: [Double?] = [Double?](repeating: 0.2, count: 8) + [Double?](repeating: 0.1, count: 8)
        let overview = RetentionOverview(cohorts: cohorts(day7: rates))
        let metric = overview.metric(day: .day7)

        #expect(metric.points == 10)
        #expect(metric.pointsLabel == "+10 pt")
        #expect(metric.isRising)
    }

    @Test("A drop reads with a minus sign")
    func drop() {
        let rates: [Double?] = [Double?](repeating: 0.1, count: 8) + [Double?](repeating: 0.2, count: 8)
        let overview = RetentionOverview(cohorts: cohorts(day7: rates))
        let metric = overview.metric(day: .day7)

        #expect(metric.pointsLabel == "−10 pt")
        #expect(!metric.isRising)
    }

    @Test("No earlier window leaves the delta empty")
    func noPrevious() {
        let overview = RetentionOverview(cohorts: cohorts(day7: [Double?](repeating: 0.2, count: 8)))
        let metric = overview.metric(day: .day7)

        #expect(metric.points == nil)
        #expect(metric.pointsLabel == "—")
    }

    @Test("A day with no matured week reads as empty")
    func emptyDay() {
        let overview = RetentionOverview(cohorts: cohorts(day7: [Double?](repeating: 0.2, count: 8)))
        let metric = overview.metric(day: .day30)

        #expect(metric.rate == nil)
        #expect(metric.rateLabel == "—")
    }

    @Test("The widest bar is the largest install count in the window")
    func maxInstalls() {
        let overview = RetentionOverview(cohorts: cohorts(day7: [Double?](repeating: 0.2, count: 10)))

        #expect(overview.maxInstalls == 170)
    }
}
