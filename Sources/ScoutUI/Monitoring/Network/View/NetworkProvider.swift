//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout

@MainActor
final class NetworkProvider: ObservableObject, SeriesProvider {
    @Published var result: ProviderResult<NetworkReport>?

    init(_ result: ProviderResult<Output>? = nil) {
        self.result = result
    }

    func fetch(in database: SeriesReader) async throws -> NetworkReport {
        let categories = LatencyBuckets.categories + StatusBuckets.categories
        let series = try await database.metricSeries(
            Int.self,
            categories: categories,
            in: Date().trailingYear
        )
        return NetworkReport(series: series)
    }
}
