//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension RetentionCohort {
    /// Builds the weekly retention table from local lifecycle data — the
    /// client-side twin of the server's `RetentionService`.
    ///
    /// Installs are grouped into acquisition cohorts by the UTC week of their
    /// install day. For each install and milestone in `dayOffsets`, bounded
    /// day-N retention asks whether the install was active on exactly
    /// `install day + N` — i.e. whether `sessionDays[install]` contains that
    /// day. A milestone whose window has not fully elapsed by `asOf` (the whole
    /// cohort week plus the offset) is left `nil`, forming the table's
    /// triangular gap.
    ///
    /// - Parameters:
    ///   - installDays: install id → the moment that install was first seen.
    ///   - sessionDays: install id → the set of UTC day-starts it was active on.
    ///   - range: the install days to include, as a half-open range.
    ///   - asOf: the maturity cutoff, normally now.
    /// - Returns: one cohort per install week in `range`, sorted by week ascending.
    ///
    public static func build(
        installDays: [String: Date], sessionDays: [String: Set<Date>], in range: Range<Date>, asOf: Date
    )
        -> [RetentionCohort]
    {
        let calendar = Calendar.utc

        var sizes: [Date: Int] = [:]
        var counts: [Date: [Int: Int]] = [:]

        for (install, installDate) in installDays where range.contains(installDate) {
            let installDay = installDate.startOfDay
            let week = installDay.startOfWeek
            sizes[week, default: 0] += 1

            let active = sessionDays[install] ?? []
            for (index, offset) in dayOffsets.enumerated() {
                let target = calendar.date(byAdding: .day, value: offset, to: installDay)!
                if active.contains(target) {
                    counts[week, default: [:]][index, default: 0] += 1
                }
            }
        }

        return sizes.keys.sorted().map { week in
            let cohortCounts = counts[week] ?? [:]

            let retained = dayOffsets.enumerated().map { index, offset -> Int? in
                let matured = calendar.date(byAdding: .day, value: 6 + offset, to: week)!
                guard matured < asOf else {
                    return nil
                }
                return cohortCounts[index] ?? 0
            }

            return RetentionCohort(
                date: week.millisecondsSince1970,
                size: sizes[week] ?? 0,
                retained: retained
            )
        }
    }
}
