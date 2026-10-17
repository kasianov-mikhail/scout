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
            query: query,
            filters: [
                query.name.map { "name=\(Self.encode($0))" }
            ]
        )
    }

    func seriesEndpoint(for query: LifecycleSeriesQuery) -> URL? {
        seriesEndpoint(
            source: "lifecycle",
            query: query,
            filters: [
                "name=\(Self.encode(query.name))",
                query.byVersion ? "by=version" : nil,
            ]
        )
    }

    func seriesEndpoint(for query: MetricSeriesQuery) -> URL? {
        seriesEndpoint(
            source: "metric",
            query: query,
            filters: [
                query.name.map { "name=\(Self.encode($0))" },
                query.category.map { "category=\(Self.encode($0))" },
                query.values.map { "values=\(Self.encode($0.rawValue))" },
                query.reduce == .sum ? nil : "reduce=\(query.reduce.rawValue)",
            ]
        )
    }

    private func seriesEndpoint(source: String, query: some SeriesQuery, filters: [String?]) -> URL? {
        let params: [String?] =
            [
                "bucket=\(query.bucket.rawValue)",
                query.range.queryParameters,
                "source=\(source)",
            ] + filters

        return URL(string: "api/v1/metrics/series?" + params.compactMap(\.self).joined(separator: "&"), relativeTo: url)
    }

    private struct MetricSeriesResponse: Decodable {
        let series: [MetricSeries]
    }
}
