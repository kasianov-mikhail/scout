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

    func seriesEndpoint(for query: some SeriesQuery) -> URL? {
        let dimensions = query.dimensions

        let params: [String?] = [
            "bucket=\(dimensions.bucket.rawValue)",
            query.range.queryParameters,
            "source=\(dimensions.source)",
            dimensions.name.map { "name=\(Self.encode($0))" },
            dimensions.category.map { "category=\(Self.encode($0))" },
            dimensions.values.map { "values=\(Self.encode($0.rawValue))" },
            dimensions.byVersion ? "by=version" : nil,
            dimensions.reduce == .sum ? nil : "reduce=\(dimensions.reduce.rawValue)",
        ]

        return URL(string: "api/v1/metrics/series?" + params.compactMap(\.self).joined(separator: "&"), relativeTo: url)
    }

    private struct MetricSeriesResponse: Decodable {
        let series: [MetricSeries]
    }
}
