//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension CachingDatabase: SeriesReader {
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
        let lower = query.bucket.start(of: query.range.lowerBound)
        let frozenUpper = query.bucket.start(of: min(query.range.upperBound, now().startOfWeek.addingWeek(-1)))

        guard lower < frozenUpper else {
            return try await fetch(query)
        }

        let fingerprint = [scope, "series", query.fingerprint].joined(separator: "|")
        let cached = await cachedSpan(for: fingerprint, in: lower..<frozenUpper)
        let cachedUpper = cached.map { query.bucket.start(of: $0.upper) } ?? lower
        let records = cached?.records.filter { $0.isDated(before: cachedUpper) } ?? []

        guard cachedUpper < query.range.upperBound else {
            return MetricSeries.combined(cached: records, fetched: [])
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

        return MetricSeries.combined(cached: records, fetched: fetched)
    }
}

extension Record {
    fileprivate func isDated(before upper: Date) -> Bool {
        let date: Date? = self["date"]
        return date.map { $0 < upper } ?? false
    }
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
                MetricSeries(key: key, points: points.sorted { $0.date < $1.date })
            }
    }
}
