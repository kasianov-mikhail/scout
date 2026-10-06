//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import ScoutDB

struct NativeMetricSeries {
    let query: MetricSeriesQuery
    let store: EntityStore

    func series() async throws -> [MetricSeries] {
        if query.reduce == .last {
            return try await LastValueSeries(query: query, store: store).series()
        }

        async let ints = query.values == .double ? SeriesTotals() : totals(values: .int)
        async let doubles = query.values == .int ? SeriesTotals() : totals(values: .double)

        return try await [MetricSeries](
            ints: ints.series(values: .int),
            doubles: doubles.series(values: .double),
            values: query.values
        )
    }

    private func totals(values: MetricSeriesQuery.Values) async throws -> SeriesTotals {
        let points = try await store.query(values.metricsEntity).series(
            "value",
            metric: .sum,
            group: EntityCatalog.metricSeriesKey,
            in: query.window
        )

        return SeriesTotals(points: points, bucket: query.bucket) { group in
            guard let (category, metric) = EntityCatalog.decodeSeriesKey(group) else {
                return nil
            }
            guard query.matches(name: metric, category: category) else {
                return nil
            }

            return SeriesKey(metric: metric, category: category)
        }
    }
}

extension MetricSeriesQuery.Values {
    var metricsEntity: String {
        switch self {
        case .int:
            IntMetricsEntry.recordType
        case .double:
            DoubleMetricsEntry.recordType
        }
    }
}

extension SeriesKey {
    init(metric: String, category: String?) {
        self.init(name: metric, category: category.flatMap { $0.isEmpty ? nil : $0 }, version: nil)
    }
}
