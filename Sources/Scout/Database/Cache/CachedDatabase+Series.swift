//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension CachedDatabase: SeriesReader {
    package func eventSeries(matching query: EventSeriesQuery) async throws -> [MetricSeries] {
        try await series(matching: query, fetch: base.eventSeries)
    }

    package func lifecycleSeries(matching query: LifecycleSeriesQuery) async throws -> [MetricSeries] {
        try await series(matching: query, fetch: base.lifecycleSeries)
    }

    package func metricSeries(matching query: MetricSeriesQuery) async throws -> [MetricSeries] {
        try await series(matching: query, fetch: base.metricSeries)
    }

    private func series<Query: SeriesQuery>(matching query: Query, fetch: (Query) async throws -> [MetricSeries]) async throws -> [MetricSeries] {
        let settledCutoff = now().startOfWeek.addingWeek(-1)
        let frozenUpper = min(query.range.upperBound, settledCutoff)

        guard query.range.lowerBound < frozenUpper else {
            return try await fetch(query)
        }

        let fingerprint = ([scope, "series"] + query.dimensions.components).joined(separator: "|")

        var cached: [Record] = []
        var cachedUpper = query.range.lowerBound

        if let covered = await cache.coveredRange(for: fingerprint), covered.lowerBound <= query.range.lowerBound, covered.upperBound > query.range.lowerBound {
            let upper = min(covered.upperBound, frozenUpper)

            if let records = await cache.records(for: fingerprint, in: query.range.lowerBound..<upper) {
                cached = records
                cachedUpper = upper
            }
        }

        guard cachedUpper < query.range.upperBound else {
            return [MetricSeries](cached: cached, fetched: [])
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

        return [MetricSeries](cached: cached, fetched: fetched)
    }
}

extension [MetricSeries] {
    var cacheRecords: [Record] {
        flatMap { series in
            series.points.map { point in
                var record = Record(recordType: "MetricSeriesPoint", recordID: UUID().uuidString)
                record.fields["date"] = .date(Date(millisecondsSince1970: point.date))
                record.fields["name"] = .string(series.name)
                record.fields["category"] = series.category.map(RecordValue.string)
                record.fields["app_version"] = series.version.map(RecordValue.string)

                switch point.value {
                case .int(let value):
                    record.fields["value"] = .int(Int64(value))
                case .double(let value):
                    record.fields["value"] = .double(value)
                }

                return record
            }
        }
    }

    init(cached: [Record], fetched: [MetricSeries]) {
        var points: [SeriesKey: [MetricSeriesPoint]] = [:]

        for record in cached {
            guard case .date(let date)? = record.fields["date"] else {
                continue
            }
            guard case .string(let name)? = record.fields["name"] else {
                continue
            }

            let value: MetricValue

            switch record.fields["value"] {
            case .int(let integer)?:
                value = .int(Int(integer))
            case .double(let double)?:
                value = .double(double)
            default:
                continue
            }

            let category: String? =
                if case .string(let category)? = record.fields["category"] { category } else { nil }
            let version: String? =
                if case .string(let version)? = record.fields["app_version"] { version } else { nil }

            let key = SeriesKey(
                name: name,
                category: category,
                version: version
            )

            points[key, default: []].append(MetricSeriesPoint(date: date.millisecondsSince1970, value: value))
        }

        for series in fetched {
            points[series.key, default: []] += series.points
        }

        self = points.sorted { $0.key < $1.key }
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
