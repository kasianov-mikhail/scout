//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct RetentionOverview {
    let weeks: [RetentionCohort]
    let previousWeeks: [RetentionCohort]

    init(cohorts: [RetentionCohort]) {
        let sorted = cohorts.sorted(by: >)

        self.weeks = Array(sorted.prefix(8))
        self.previousWeeks = Array(sorted.dropFirst(8).prefix(8))
    }

    var maxInstalls: Int {
        weeks.map(\.size).max() ?? 0
    }

    func kept(day: RetentionDay) -> Int {
        weeks.compactMap { $0.kept(onDay: day) }.reduce(0, +)
    }

    func keptLabel(day: RetentionDay) -> String {
        kept(day: day).formatted(.count)
    }

    func average(day: RetentionDay) -> Double? {
        weeks.average(onDay: day.rawValue)
    }

    func metric(day: RetentionDay) -> RetentionMetric {
        let rate = average(day: day)
        let previous = previousWeeks.average(onDay: day.rawValue)
        var points: Int?

        if let rate, let previous {
            points = Int(((rate - previous) * 100).rounded())
        }

        return RetentionMetric(rate: rate, points: points)
    }
}

struct RetentionMetric {
    let rate: Double?
    let points: Int?

    var rateLabel: String {
        rate.map { $0.formatted(.retentionRate) } ?? "—"
    }

    var pointsLabel: String {
        guard let points else {
            return "—"
        }
        guard points != 0 else {
            return "0 pt"
        }
        return points > 0 ? "+\(points) pt" : "−\(abs(points)) pt"
    }

    var isRising: Bool {
        (points ?? 0) > 0
    }
}
