//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

class MetricsProvider<T: ChartNumeric>: QueryProvider<GridMatrix<T>> {
    private let telemetry: Telemetry.Export

    init(telemetry: Telemetry.Export) {
        self.telemetry = telemetry
        super.init {
            RecordQuery(
                recordType: T.recordType,
                filters: Calendar.utc.defaultRange.dateFilters + [
                    RecordFilter(field: "category", op: .equals, value: .string(telemetry.rawValue))
                ]
            )
        }
    }

    /// A Scout server aggregates these series natively, so fetch the flat
    /// per-name series for the category and rebuild the grid the chart consumes.
    ///
    /// CloudKit backends still answer the `DateIntMatrix` / `DateDoubleMatrix`
    /// query the initializer builds.
    ///
    override func fetch(in database: AppDatabase) async throws -> [GridMatrix<T>] {
        let series = try await database.metricSeries(
            category: telemetry.rawValue,
            values: T.seriesValues,
            in: Calendar.utc.defaultRange
        )
        guard let series else {
            return try await super.fetch(in: database)
        }
        return series.gridMatrices()
    }
}
