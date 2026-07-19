//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

@MainActor
final class SearchSeriesProvider: ObservableObject, Provider {
    @Published var result: ProviderResult<[MetricSeries]>?

    func fetch(in database: DatabaseReader) async throws -> [MetricSeries] {
        try await database.series(
            matching: SeriesQuery(bucket: .week, range: Calendar.utc.defaultRange)
        )
    }
}
