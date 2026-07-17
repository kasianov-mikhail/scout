//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import ScoutCore

@MainActor
class StatProvider: ObservableObject, Provider {
    @Published var result: ProviderResult<[ChartPoint<Int>]>?

    let eventName: String
    let periods: [Period]

    init(eventName: String, periods: [Period]) {
        self.eventName = eventName
        self.periods = periods
    }

    func fetch(in database: DatabaseReader) async throws -> [ChartPoint<Int>] {
        let series = try await database.series(
            matching: SeriesQuery(name: eventName, bucket: .hour, range: Calendar.utc.defaultRange)
        )
        return series.flatMap { $0.chartPoints() }
    }
}
