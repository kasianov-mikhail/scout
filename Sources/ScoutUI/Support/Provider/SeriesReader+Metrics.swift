//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension SeriesReader {
    func metricSeries<T: MetricScalar>(_ valueType: T.Type, name: String? = nil, category: String, reduce: MetricSeriesQuery.Reduce = .sum, in range: Range<Date>) async throws -> [MetricSeries] {
        try await metricSeries(
            matching: MetricSeriesQuery(
                name: name,
                category: category,
                values: T.seriesValues,
                bucket: .hour,
                reduce: reduce,
                range: range
            )
        )
    }

    func metricSeries<T: MetricScalar>(_ valueType: T.Type, name: String? = nil, categories: [String], in range: Range<Date>) async throws -> [MetricSeries] {
        try await withThrowingTaskGroup(of: [MetricSeries].self) { group in
            for category in categories {
                group.addTask {
                    try await self.metricSeries(T.self, name: name, category: category, in: range)
                }
            }

            var series: [MetricSeries] = []

            for try await chunk in group {
                series += chunk
            }

            return series
        }
    }
}
