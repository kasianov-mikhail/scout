//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension RetentionCohort {
    package static func build(
        installDays: [String: Date], sessionDays: [String: Set<Date>], in range: Range<Date>, asOf: Date
    ) -> [RetentionCohort] {
        var sizes: [Date: Int] = [:]
        var counts: [Date: [Int: Int]] = [:]

        for (install, installDate) in installDays where range.contains(installDate) {
            let installDay = installDate.startOfDay
            let week = installDay.startOfWeek
            sizes[week, default: 0] += 1

            let active = sessionDays[install] ?? []
            for (index, offset) in dayOffsets.enumerated() {
                let target = installDay.addingDay(offset)
                if active.contains(target) {
                    counts[week, default: [:]][index, default: 0] += 1
                }
            }
        }

        return sizes.keys.sorted().map { week in
            let cohortCounts = counts[week] ?? [:]

            let retained = dayOffsets.enumerated().map { index, offset -> Int? in
                let matured = week.addingDay(7 + offset)
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
