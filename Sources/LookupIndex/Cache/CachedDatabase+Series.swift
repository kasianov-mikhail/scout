//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ConnectorSupport
import Foundation
import Scout

@available(iOS 18, macOS 15, *)
extension CachedDatabase: SeriesReader {
    func eventSeries(matching query: EventSeriesQuery) async throws -> [MetricSeries] {
        try await series(matching: query, fetch: base.eventSeries)
    }

    func lifecycleSeries(matching query: LifecycleSeriesQuery) async throws -> [MetricSeries] {
        try await series(matching: query, fetch: base.lifecycleSeries)
    }

    func metricSeries(matching query: MetricSeriesQuery) async throws -> [MetricSeries] {
        try await series(matching: query, fetch: base.metricSeries)
    }

    private func series<Query: CacheableQuery>(matching query: Query, fetch: (Query) async throws -> [MetricSeries]) async throws -> [MetricSeries] {
        let frozenUpper = min(query.range.upperBound, now().startOfWeek.addingWeek(-1))

        guard query.range.lowerBound < frozenUpper else {
            return try await fetch(query)
        }

        let fingerprint = [scope, "series", query.fingerprint].joined(separator: "|")
        let frozen = query.range.lowerBound..<frozenUpper
        let cached = await cachedSpan(for: fingerprint, in: frozen)
        let cachedUpper = cached?.upper ?? frozen.lowerBound

        guard cachedUpper < query.range.upperBound else {
            return MetricSeries.combined(cached: cached?.records ?? [], fetched: [])
        }

        var remainder = query
        remainder.range = cachedUpper..<query.range.upperBound
        let fetched = try await fetch(remainder)

        if cachedUpper < frozenUpper {
            await cache.store(
                fetched.cacheRecords,
                for: fingerprint,
                covering: cachedUpper..<frozenUpper
            )
        }

        return MetricSeries.combined(cached: cached?.records ?? [], fetched: fetched)
    }

    private func cachedSpan(for fingerprint: String, in frozen: Range<Date>) async -> CoveredSpan? {
        guard let covered = await cache.coveredRange(for: fingerprint) else {
            return nil
        }
        guard covered.lowerBound <= frozen.lowerBound, covered.upperBound > frozen.lowerBound else {
            return nil
        }

        let upper = min(covered.upperBound, frozen.upperBound)

        guard let records = await cache.records(for: fingerprint, in: frozen.lowerBound..<upper) else {
            return nil
        }

        return CoveredSpan(records: records, upper: upper)
    }
}

private struct CoveredSpan {
    let records: [Record]
    let upper: Date
}

private struct CachedPoint {
    let key: SeriesKey
    let point: MetricSeriesPoint

    init?(record: Record) {
        let date: Date? = record["date"]
        let name: String? = record["name"]
        let double: Double? = record["value"]
        let integer: Int64? = record["value"]

        guard let date, let name, let value = double ?? integer.map({ Double($0) }) else {
            return nil
        }

        key = SeriesKey(name: name, category: record["category"], version: record["app_version"])
        point = MetricSeriesPoint(date: date, value: value)
    }
}

extension [MetricSeries] {
    var cacheRecords: [Record] {
        flatMap { series in
            series.points.map { point in
                var record = Record(recordType: "MetricSeriesPoint", recordID: UUID().uuidString)
                record["date"] = point.date
                record["name"] = series.name
                record["category"] = series.category
                record["app_version"] = series.version
                record["value"] = point.value

                return record
            }
        }
    }
}

extension MetricSeries {
    static func combined(cached: [Record], fetched: [MetricSeries]) -> [MetricSeries] {
        var points: [SeriesKey: [MetricSeriesPoint]] = [:]

        for case let cached? in cached.map(CachedPoint.init) {
            points[cached.key, default: []].append(cached.point)
        }

        for series in fetched {
            points[series.key, default: []] += series.points
        }

        return points.sorted { $0.key < $1.key }
            .map { key, points in
                MetricSeries(
                    name: key.name,
                    category: key.category,
                    version: key.version,
                    points: points.sorted { $0.date < $1.date }
                )
            }
    }
}
