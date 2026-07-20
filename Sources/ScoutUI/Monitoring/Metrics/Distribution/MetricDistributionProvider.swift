//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout

class MetricDistributionProvider<H: QuantileHistogram>: ObservableObject, Provider {
    @Published var result: ProviderResult<MetricDistribution<H>>?

    private let name: String
    private let categories: [String]

    init(name: String, categories: [String]) {
        self.name = name
        self.categories = categories
    }

    func fetch(in database: DatabaseReader) async throws -> MetricDistribution<H> {
        let range = Calendar.utc.defaultRange
        let name = self.name

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

        return MetricDistribution(series: series.filter { $0.name == name })
    }
}
