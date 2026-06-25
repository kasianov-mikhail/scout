//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

@testable import Scout

/// Client-side reconstruction of the aggregate series a Scout server would
/// serve, folded out of the matrix records a stub database holds.
///
/// A real backend that cannot aggregate (CloudKit) leans on these same
/// matrices, so the stubs rebuild `activity` and `metricSeries` from the
/// stored `PeriodMatrix` / grid records exactly as a client reading them
/// would.
///
extension RecordReader {
    /// Folds `ActiveUser` `PeriodMatrix` records over `range` back into a
    /// DAU/WAU/MAU series, one point per day that carries any activity.
    ///
    func reconstructedActivity(in range: Range<Date>) async throws -> [ActivityPoint] {
        let query = RecordQuery(recordType: PeriodMatrix.self, filters: range.dateFilters)
        let matrices = try await readAll(matching: query, fields: nil)
            .map(PeriodMatrix.init)

        var byDay: [Int64: (dau: Int, wau: Int, mau: Int)] = [:]

        for matrix in matrices {
            for cell in matrix.cells {
                let date = matrix.date.addingTimeInterval(TimeInterval(cell.day * 86_400))
                var point = byDay[date.millisecondsSince1970] ?? (0, 0, 0)
                switch cell.period {
                case .daily:
                    point.dau += cell.value
                case .weekly:
                    point.wau += cell.value
                case .monthly:
                    point.mau += cell.value
                }
                byDay[date.millisecondsSince1970] = point
            }
        }

        return byDay.map { date, point in
            ActivityPoint(date: date, dau: point.dau, wau: point.wau, mau: point.mau)
        }
    }

    /// Folds the grid matrices of `category` over `range` back into a flat
    /// per-name metric series, one point per cell. `values` selects the value
    /// flavor (`"int"` / `"double"`) and so the grid record type.
    ///
    func reconstructedMetricSeries(category: String, values: String, in range: Range<Date>) async throws -> [MetricSeries] {
        guard values == Int.seriesValues else {
            return try await metricSeries(category: category, in: range) { (value: Double) in .double(value) }
        }
        return try await metricSeries(category: category, in: range) { (value: Int) in .int(value) }
    }

    private func metricSeries<T: MatrixValue>(category: String, in range: Range<Date>, wrap: (T) -> MetricValue) async throws -> [MetricSeries] {
        let category = RecordQuery.Filter(field: "category", op: .equals, value: .string(category))
        let query = RecordQuery(recordType: GridMatrix<T>.self, filters: range.dateFilters + [category])
        let matrices = try await readAll(matching: query, fields: nil)
            .map(GridMatrix<T>.init)

        return matrices.map { matrix in
            let points = matrix.cells.map { cell -> MetricSeriesPoint in
                let date = matrix.date.addingTimeInterval(TimeInterval(cell.secondsSinceBase))
                return MetricSeriesPoint(date: date.millisecondsSince1970, value: wrap(cell.value))
            }
            return MetricSeries(name: matrix.name, category: matrix.category, points: points)
        }
    }
}

private typealias PeriodMatrix = Matrix<PeriodCell<Int>>
