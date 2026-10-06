//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import ScoutDB

struct NativeEventSeries {
    let query: EventSeriesQuery
    let store: EntityStore

    func series() async throws -> [MetricSeries] {
        let events = store.query(EventEntry.recordType)
        let named = query.name.map { events.filter("name", .equals, .string($0)) } ?? events

        let points = try await named.series(
            metric: .sum,
            group: "name",
            in: query.window
        )

        let totals = SeriesTotals(points: points, bucket: query.bucket) { group in
            query.name == nil || group == query.name ? SeriesKey(name: group, category: nil, version: nil) : nil
        }

        return totals.series(values: .int)
    }
}
