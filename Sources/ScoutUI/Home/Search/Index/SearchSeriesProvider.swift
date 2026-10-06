//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

@MainActor
final class SearchSeriesProvider: ObservableObject, SeriesProvider {
    @Published var result: ProviderResult<[MetricSeries]>?

    func fetch(in database: SeriesReader) async throws -> [MetricSeries] {
        let range = Date().trailingYear

        async let events = database.eventSeries(
            matching: EventSeriesQuery(bucket: .week, range: range)
        )
        async let metrics = database.metricSeries(
            matching: MetricSeriesQuery(bucket: .week, range: range)
        )

        return try await events + metrics
    }
}
