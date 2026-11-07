//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct RetentionCohortDetail {
    let cohort: RetentionCohort
    let averages: [RetentionCohort]
    let now: Date

    init(cohort: RetentionCohort, cohorts: [RetentionCohort], now: Date) {
        self.cohort = cohort
        self.averages = cohorts.matured
        self.now = now
    }

    var installsLabel: String {
        cohort.size.formatted(.count)
    }

    var subtitle: String {
        "\(cohort.size == 1 ? "install" : "installs") · \(cohort.weekRange)"
    }

    var averageNote: String {
        "average of \(averages.count) weeks"
    }

    var days: [RetentionDayValue] {
        RetentionDay.allCases.map { day in
            let rate = RetentionCohort.rate(retention: cohort.retention, onDay: day.rawValue)

            return RetentionDayValue(
                day: day,
                size: cohort.size,
                rate: rate,
                average: averages.average(onDay: day.rawValue),
                pending: rate == nil ? day.pendingLabel(week: cohort.id, now: now) : nil
            )
        }
    }

    var segments: [RetentionSegmentValue] {
        cohort.segments.map { segment in
            let rate = RetentionCohort.rate(retention: segment.retention, onDay: RetentionDay.day7.rawValue)

            return RetentionSegmentValue(
                segment: segment,
                rate: rate,
                kept: rate.map { $0.kept(in: segment.size) },
                pending: rate == nil ? RetentionDay.day7.pendingLabel(week: cohort.id, now: now) : nil
            )
        }
    }
}
