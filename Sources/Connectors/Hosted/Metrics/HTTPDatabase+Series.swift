//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension HTTPDatabase: SeriesReader {
    func eventSeries(matching query: EventSeriesQuery) async throws -> [MetricSeries] {
        try await series(from: seriesEndpoint(for: query))
    }

    func lifecycleSeries(matching query: LifecycleSeriesQuery) async throws -> [MetricSeries] {
        try await series(from: seriesEndpoint(for: query))
    }

    func metricSeries(matching query: MetricSeriesQuery) async throws -> [MetricSeries] {
        try await series(from: seriesEndpoint(for: query))
    }

    private func series(from endpoint: URL?) async throws -> [MetricSeries] {
        try await get(
            from: endpoint,
            reason: "Malformed metrics URL",
            as: MetricSeriesResponse.self
        )
        .series
    }

    func seriesEndpoint(for query: EventSeriesQuery) -> URL? {
        seriesEndpoint(
            source: "event",
            bucket: query.bucket,
            range: query.range,
            filters: [
                query.name.map { "name=\(Self.encode($0))" }
            ]
        )
    }

    func seriesEndpoint(for query: LifecycleSeriesQuery) -> URL? {
        seriesEndpoint(
            source: "lifecycle",
            bucket: query.bucket,
            range: query.range,
            filters: [
                "name=\(Self.encode(query.name))",
                query.byVersion ? "by=version" : nil,
            ]
        )
    }

    func seriesEndpoint(for query: MetricSeriesQuery) -> URL? {
        seriesEndpoint(
            source: "metric",
            bucket: query.bucket,
            range: query.range,
            filters: [
                query.name.map { "name=\(Self.encode($0))" },
                query.category.map { "category=\(Self.encode($0))" },
                query.values.map { "values=\(Self.encode($0.rawValue))" },
                query.reduce == .sum ? nil : "reduce=\(query.reduce.rawValue)",
            ]
        )
    }

    private func seriesEndpoint(source: String, bucket: SeriesBucket, range: Range<Date>, filters: [String?]) -> URL? {
        let params: [String?] =
            [
                "bucket=\(bucket.rawValue)",
                range.queryParameters,
                "source=\(source)",
            ] + filters

        return URL(string: "api/v1/metrics/series?" + params.compactMap(\.self).joined(separator: "&"), relativeTo: url)
    }

    private struct MetricSeriesResponse: Decodable {
        let series: [MetricSeries]
    }
}
