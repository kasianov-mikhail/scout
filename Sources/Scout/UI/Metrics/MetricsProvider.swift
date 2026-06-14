//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

class MetricsProvider<T: ChartNumeric>: QueryProvider<GridMatrix<T>> {
    private let telemetry: Telemetry.Export

    init(telemetry: Telemetry.Export) {
        self.telemetry = telemetry
        super.init {
            let predicate = NSCompoundPredicate(
                type: .and,
                subpredicates: [
                    Calendar.utc.defaultRange.datePredicate,
                    NSPredicate(format: "category == %@", telemetry.rawValue),
                ]
            )

            return CKQuery(
                recordType: T.recordType,
                predicate: predicate
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
        guard let server = database as? MetricSeriesReading else {
            return try await super.fetch(in: database)
        }
        let series = try await server.metricSeries(
            category: telemetry.rawValue,
            values: T.seriesValues,
            in: Calendar.utc.defaultRange
        )
        return series.gridMatrices()
    }
}
