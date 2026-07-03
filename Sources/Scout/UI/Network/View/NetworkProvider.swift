//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

@MainActor
class NetworkProvider: ObservableObject, Provider {
    @Published var result: ProviderResult<NetworkReport>?

    func fetch(in database: DatabaseReader) async throws -> NetworkReport {
        let range = Calendar.utc.defaultRange
        let categories = LatencyBuckets.categories + StatusBuckets.categories

        let series = try await withThrowingTaskGroup(of: [MetricSeries].self) { group in
            for category in categories {
                group.addTask {
                    try await database.metricSeries(Int.self, category: category, in: range)
                }
            }

            var series: [MetricSeries] = []
            for try await chunk in group {
                series += chunk
            }
            return series
        }

        return NetworkReport(series: series)
    }
}

extension NetworkProvider {
    static func fixture() -> NetworkProvider {
        let provider = NetworkProvider()
        provider.result = .success(.sample)
        return provider
    }
}
