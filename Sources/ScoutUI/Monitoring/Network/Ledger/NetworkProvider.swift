//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

@MainActor
final class NetworkProvider: ObservableObject, SeriesProvider {
    @Published var result: ProviderResult<NetworkReport>?
    @Published var query: NetworkQuery

    init(_ result: ProviderResult<NetworkReport>? = nil, query: NetworkQuery = NetworkQuery(range: .today)) {
        self.result = result
        self.query = query
    }

    func fetch(in database: SeriesReader) async throws -> NetworkReport {
        let series = try await database.metricSeries(
            matching: MetricSeriesQuery(
                name: query.name,
                values: .int,
                bucket: query.bucket,
                range: query.range
            )
        )
        return NetworkReport(series: series, bucket: query.bucket)
    }
}
