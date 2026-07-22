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
final class MetricDistributionProvider<H: QuantileHistogram>: ObservableObject, Provider {
    @Published var result: ProviderResult<MetricDistribution<H>>?

    private let name: String
    private let categories: [String]

    init(name: String, categories: [String]) {
        self.name = name
        self.categories = categories
    }

    func fetch(in database: DatabaseReader) async throws -> MetricDistribution<H> {
        let series = try await database.metricSeries(
            Int.self,
            categories: categories,
            in: Calendar.utc.defaultRange
        )
        return MetricDistribution(series: series.filter { $0.name == name })
    }
}
