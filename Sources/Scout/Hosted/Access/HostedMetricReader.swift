//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension HTTPDatabase: MetricReader {
    func series(matching query: SeriesQuery) async throws -> [MetricSeries] {
        var params = [
            "bucket=\(query.bucket.rawValue)",
            "from=\(query.range.lowerBound.millisecondsSince1970)",
            "to=\(query.range.upperBound.millisecondsSince1970)",
        ]
        if let name = query.name {
            params.append("name=\(Self.encode(name))")
        }
        if let category = query.category {
            params.append("category=\(Self.encode(category))")
        }
        if let values = query.values {
            params.append("values=\(values)")
        }
        if query.byVersion {
            params.append("by=version")
        }

        let path = "api/v1/metrics/series?" + params.joined(separator: "&")
        guard let endpoint = URL(string: path, relativeTo: url) else {
            throw HTTPDatabaseError(status: 0, reason: "Malformed metrics URL")
        }

        let data = try await perform(request(for: endpoint, method: "GET"))
        return try JSONDecoder().decode(MetricSeriesResponse.self, from: data).series
    }

    private static func encode(_ value: String) -> String {
        value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
    }

    private struct MetricSeriesResponse: Decodable {
        let series: [MetricSeries]
    }
}
