//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct RetentionSegmentDetail {
    let segment: RetentionSegment
    let cohort: RetentionCohort
    let cohorts: [RetentionCohort]
    let averages: [RetentionCohort]
    let now: Date

    init(segment: RetentionSegment, cohort: RetentionCohort, cohorts: [RetentionCohort], now: Date) {
        self.segment = segment
        self.cohort = cohort
        self.cohorts = cohorts
        self.averages = cohorts.matured
        self.now = now
    }

    var installsLabel: String {
        segment.size.formatted(.count)
    }

    var subtitle: String {
        "\(segment.size == 1 ? "install" : "installs") on \(segment.name) · \(cohort.weekRange)"
    }

    var days: [RetentionDayValue] {
        RetentionDay.allCases.map { day in
            let rate = RetentionCohort.rate(retention: segment.retention, onDay: day.rawValue)
            let reference =
                RetentionCohort.rate(retention: cohort.retention, onDay: day.rawValue)
                ?? averages.average(onDay: day.rawValue)

            return RetentionDayValue(
                day: day,
                size: segment.size,
                rate: rate,
                average: reference,
                pending: rate == nil ? day.pendingLabel(week: cohort.id, now: now) : nil
            )
        }
    }

    var crash: RetentionIncidentValue {
        RetentionIncidentValue(kind: .crash, count: segment.crashes, size: segment.size, weekRate: cohort.crashRate)
    }

    var hang: RetentionIncidentValue {
        RetentionIncidentValue(kind: .hang, count: segment.hangs, size: segment.size, weekRate: cohort.hangRate)
    }

    var weeks: [RetentionSegmentWeek] {
        cohorts.recent.compactMap { cohort in
            guard let segment = cohort.segments.first(where: { $0.name == self.segment.name }) else {
                return nil
            }
            guard let rate = RetentionCohort.rate(retention: segment.retention, onDay: RetentionDay.day7.rawValue) else {
                return nil
            }

            return RetentionSegmentWeek(
                start: cohort.id,
                kept: rate.kept(in: segment.size),
                rate: rate,
                isCurrent: cohort.id == self.cohort.id
            )
        }
    }
}

extension RetentionCohort {
    fileprivate var crashRate: Double? {
        incidentRate(\.crashes)
    }

    fileprivate var hangRate: Double? {
        incidentRate(\.hangs)
    }

    fileprivate func incidentRate(_ count: KeyPath<RetentionSegment, Int>) -> Double? {
        let size = segments.reduce(0) { $0 + $1.size }
        guard size > 0 else {
            return nil
        }
        let total = segments.reduce(0) { $0 + $1[keyPath: count] }
        return Double(total) / Double(size)
    }
}
