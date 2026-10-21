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
        let points = try await points(values: values)

        switch query.reduce {
        case .last:
            var peaks = SeriesPeaks()

            for point in points {
                peaks.add(point.value, key: point.key, start: point.start)
            }

            return peaks.series

        case .sum:
            var totals = SeriesTotals()

            for point in points {
                totals.add(point.value, key: point.key, start: point.start)
            }

            return totals.series
        }
    }

    private func points(values: MetricSeriesQuery.Values) async throws -> [KeyedPoint] {
        let metrics = store.query(values.metricsEntity)
        let keyed = query.seriesKey.map { metrics.filter(CatalogEntry.metricSeriesKey, .equals, .string($0)) } ?? metrics

        let points = try await keyed.series(
            "value",
            metric: query.reduce.metric,
            group: CatalogEntry.metricSeriesKey,
            in: query.bucket.start(of: query.range.lowerBound)..<query.range.upperBound
        )

        return points.compactMap {
            KeyedPoint(point: $0, query: query)
        }
    }

    private struct KeyedPoint {
        let key: SeriesKey
        let start: Date
        let value: Double

        init?(point: SeriesPoint, query: MetricSeriesQuery) {
            guard let (category, metric) = CatalogEntry.decodeSeriesKey(point.group) else {
                return nil
            }
            guard let key = query.key(metric: metric, category: category) else {
                return nil
            }

            self.key = key
            self.start = query.bucket.start(of: point.date)
            self.value = point.value
        }
    }
}

extension MetricSeriesQuery.Reduce {
    fileprivate var metric: ScoutDB.Metric {
        switch self {
        case .sum:
            .sum
        case .last:
            .max
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

extension MetricSeriesQuery {
    var seriesKey: String? {
        guard let name, let category else {
            return nil
        }
        return CatalogEntry.encodeSeriesKey(category: category, name: name)
    }

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
