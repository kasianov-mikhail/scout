//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ConnectorSupport
import Foundation
import Scout
import ScoutDB

struct NativeMetricScanner {
    let query: MetricSeriesQuery
    let store: EntityStore

    var series: [MetricSeries] {
        get async throws {
            async let ints = query.values == .double ? [] : series(values: .int)
            async let doubles = query.values == .int ? [] : series(values: .double)

            switch query.reduce {
            case .sum:
                return try await MetricSeries.merge(ints: ints, doubles: doubles, values: query.values)

            case .last:
                return try await (ints + doubles).sorted { $0.key < $1.key }
            }
        }
    }

    private func series(values: MetricSeriesQuery.Values) async throws -> [MetricSeries] {
        switch query.reduce {
        case .last:
            try await NativeLastValueScanner(query: query, store: store).series(values: values)
        case .sum:
            try await totals(values: values).series
        }
    }

    private func totals(values: MetricSeriesQuery.Values) async throws -> SeriesTotals {
        let points = try await store.query(values.metricsEntity).series(
            "value",
            metric: .sum,
            group: EntityCatalog.metricSeriesKey,
            in: query.bucket.start(of: query.range.lowerBound)..<query.range.upperBound
        )

        var totals = SeriesTotals()

        for point in points {
            guard let (category, metric) = EntityCatalog.decodeSeriesKey(point.group) else {
                continue
            }
            guard let key = query.key(metric: metric, category: category) else {
                continue
            }

            totals.add(
                point.value,
                key: key,
                start: query.bucket.start(of: point.date)
            )
        }

        return totals
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

extension MetricSeriesQuery {
    func key(metric: String, category: String?) -> SeriesKey? {
        guard name == nil || name == metric else {
            return nil
        }
        guard self.category == nil || self.category == category else {
            return nil
        }

        return SeriesKey(name: metric, category: category.flatMap { $0.isEmpty ? nil : $0 }, version: nil)
    }
}
