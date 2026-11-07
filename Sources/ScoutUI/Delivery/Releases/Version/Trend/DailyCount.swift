//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct DailyCount: Equatable {
    let date: Date
    let count: Int
}

extension [DailyCount] {
    init(counts: [Date: Int] = [:], window: Range<Date>) {
        self = sequence(first: window.lowerBound) { $0.addingDay() }
            .prefix { $0 < window.upperBound }
            .map { day in DailyCount(date: day, count: counts[day] ?? 0) }
    }
}

extension [MetricSeries] {
    func dailyCounts(version: String, window: Range<Date>) -> [DailyCount] {
        var counts: [Date: Int] = [:]
        for series in self where series.version == version {
            for point in series.points where window.contains(point.date) {
                counts[point.date.startOfDay, default: 0] += Int(point.value)
            }
        }
        return [DailyCount](counts: counts, window: window)
    }
}
