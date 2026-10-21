//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct VersionTrend {
    let crashes: [DailyCount]
    let hangs: [DailyCount]
    let resources: [DailyCount]
}

extension VersionTrend {
    static var empty: VersionTrend {
        let days = [DailyCount](window: Date().trailingTwoWeeks)
        return VersionTrend(crashes: days, hangs: days, resources: days)
    }

    static var sample: VersionTrend {
        let days = [DailyCount](window: Date().trailingTwoWeeks)

        func counts(_ values: [Int]) -> [DailyCount] {
            zip(days, values).map { day, value in DailyCount(date: day.date, count: value) }
        }

        return VersionTrend(
            crashes: counts([0, 1, 0, 2, 1, 0, 0, 3, 1, 0, 2, 1, 2, 1]),
            hangs: counts([1, 0, 0, 1, 0, 2, 1, 0, 0, 1, 1, 0, 1, 1]),
            resources: counts([0, 0, 1, 0, 0, 0, 2, 0, 1, 0, 0, 1, 0, 4])
        )
    }
}
