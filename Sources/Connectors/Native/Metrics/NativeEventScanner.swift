//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ConnectorSupport
import Foundation
import Scout
import ScoutDB

struct NativeEventScanner {
    let query: EventSeriesQuery
    let store: EntityStore

    var series: [MetricSeries] {
        get async throws {
            let events = store.query(EventEntry.recordType)
            let named = query.name.map { events.filter("name", .equals, .string($0)) } ?? events

            let points = try await named.series(
                metric: .sum,
                group: "name",
                in: query.bucket.start(of: query.range.lowerBound)..<query.range.upperBound
            )

            var totals = SeriesTotals()

            for point in points {
                totals.add(
                    point.value,
                    key: SeriesKey(name: point.group, category: nil, version: nil),
                    start: query.bucket.start(of: point.date)
                )
            }

            return totals.series
        }
    }
}
