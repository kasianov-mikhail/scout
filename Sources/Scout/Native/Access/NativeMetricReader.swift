//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

extension CKDatabase: MetricReader {}

extension MetricReader {
    func metricSeries<T: SeriesScalar>(_ valueType: T.Type, category: String, in range: Range<Date>) async throws -> [MetricSeries] {
        let categoryFilter = RecordQuery.Filter(
            field: "category",
            op: .equals,
            value: .string(category)
        )

        let query = RecordQuery(
            recordType: GridMatrix<T>.self,
            filters: range.dateFilters + [categoryFilter]
        )

        return try await readAll(matching: query, fields: nil)
            .map(GridMatrix<T>.init)
            .map(MetricSeries.init)
    }
}

extension MetricSeries {
    fileprivate init(matrix: GridMatrix<some SeriesScalar>) {
        self.name = matrix.name
        self.category = matrix.category
        self.points = MetricSeriesPoint.points(from: matrix)
    }
}

extension MetricSeriesPoint {
    fileprivate static func points(from matrix: GridMatrix<some SeriesScalar>) -> [MetricSeriesPoint] {
        matrix.cells.map { cell in
            let date = matrix.date.addingTimeInterval(TimeInterval(cell.secondsSinceBase))
            return MetricSeriesPoint(date: date.millisecondsSince1970, value: cell.value.metricValue)
        }
    }
}
