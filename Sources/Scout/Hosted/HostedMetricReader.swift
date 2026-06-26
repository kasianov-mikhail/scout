//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension HTTPDatabase: MetricReader {
    func metricSeries<T: SeriesScalar>(_ valueType: T.Type, category: String, in range: Range<Date>) async throws -> [MetricSeries] {
        let from = range.lowerBound.millisecondsSince1970
        let to = range.upperBound.millisecondsSince1970
        let category = category.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? category

        let path = "api/v1/metrics/series?category=\(category)&values=\(T.seriesValues)&bucket=hour&dense=false&from=\(from)&to=\(to)"
        guard let endpoint = URL(string: path, relativeTo: url) else {
            throw HTTPDatabaseError(status: 0, reason: "Malformed metrics URL")
        }

        let data = try await perform(request(for: endpoint, method: "GET"))
        return try JSONDecoder().decode(MetricSeriesResponse.self, from: data).series
    }

    private struct MetricSeriesResponse: Decodable {
        let series: [MetricSeries]
    }
}
