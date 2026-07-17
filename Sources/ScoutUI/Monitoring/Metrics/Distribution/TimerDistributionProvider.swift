//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import ScoutCore

class TimerDistributionProvider: ObservableObject, Provider {
    @Published var result: ProviderResult<TimerDistribution>?

    private let name: String

    init(name: String) {
        self.name = name
    }

    func fetch(in database: DatabaseReader) async throws -> TimerDistribution {
        let range = Calendar.utc.defaultRange
        let name = self.name

        let series = try await withThrowingTaskGroup(of: [MetricSeries].self) { group in
            for category in LatencyBuckets.categories {
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

        return TimerDistribution(series: series.filter { $0.name == name })
    }
}
