//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Matrix where T == PeriodCell<Int> {
    /// Rebuilds the monthly activity matrices the chart consumes from a Scout
    /// server's flat DAU/WAU/MAU series.
    ///
    /// Each day contributes one cell per period to its month's matrix, matching
    /// the `PeriodMatrix` shape a CloudKit client would have produced — the
    /// matrix base date is the month start and a cell's `day` is its 0-based
    /// day-of-month offset. Zero-activity days are dropped, since they never
    /// surface as cells.
    ///
    static func from(series: [ActiveUserPoint]) -> [ActivityMatrix] {
        let calendar = Calendar.utc
        var byMonth: [Date: [PeriodCell<Int>]] = [:]

        for point in series {
            let day = Date(timeIntervalSince1970: Double(point.date) / 1000)
            let month = day.startOfMonth
            let index = calendar.dateComponents([.day], from: month, to: day).day ?? 0

            for (period, value) in [
                (ActivityPeriod.daily, point.dau),
                (ActivityPeriod.weekly, point.wau),
                (ActivityPeriod.monthly, point.mau),
            ] where value > 0 {
                byMonth[month, default: []].append(
                    PeriodCell(period: period, day: index, value: value)
                )
            }
        }

        return byMonth.map { month, cells in
            ActivityMatrix(
                recordType: PeriodCell<Int>.recordType,
                date: month,
                name: "ActiveUser",
                category: nil,
                record: nil,
                cells: cells
            )
        }
    }
}
