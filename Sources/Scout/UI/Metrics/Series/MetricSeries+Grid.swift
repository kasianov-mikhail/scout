//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Sequence where Element == MetricSeries {
    /// Rebuilds the weekly `GridMatrix` objects the chart consumes from a Scout
    /// server's flat per-name series.
    ///
    /// Each point lands in its week's matrix at the `cell_<weekday>_<hour>`
    /// position a CloudKit client would have written, so the rest of the
    /// metrics pipeline (`pointGroups`, the chart) is unchanged. The server
    /// sends sparse hourly buckets, so every point is a real cell — there are
    /// no zero-fills to drop.
    ///
    func gridMatrices<T: ChartNumeric>() -> [GridMatrix<T>] {
        let calendar = Calendar.utc
        var byWeek: [WeekKey: [GridCell<T>]] = [:]

        for series in self {
            for point in series.points {
                let date = Date(timeIntervalSince1970: Double(point.date) / 1000)
                let key = WeekKey(name: series.name, category: series.category, week: date.startOfWeek)
                byWeek[key, default: []].append(
                    GridCell(
                        row: calendar.component(.weekday, from: date),
                        column: calendar.component(.hour, from: date),
                        value: T.chartValue(point.value)
                    )
                )
            }
        }

        return byWeek.map { key, cells in
            GridMatrix(
                recordType: T.recordType,
                date: key.week,
                name: key.name,
                category: key.category,
                record: nil,
                cells: cells
            )
        }
    }
}

private struct WeekKey: Hashable {
    let name: String
    let category: String?
    let week: Date
}
