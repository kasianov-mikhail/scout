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

struct NativeLifecycleScanner {
    let query: LifecycleSeriesQuery
    let store: EntityStore

    var series: [MetricSeries] {
        get async throws {
            let range = query.bucket.start(of: query.range.lowerBound)..<query.range.upperBound
            let source = LifecycleSource(name: query.name)

            let points = try await store.query(source.entity).series(
                source.field,
                metric: .sum,
                group: CatalogEntry.lifecycleKey,
                in: range
            )

            var totals = SeriesTotals()

            for point in points {
                let key = LifecycleKey(point.group)

                guard !source.isNamed || key.name == query.name else {
                    continue
                }

                let series = SeriesKey(
                    name: query.name,
                    category: key.category,
                    version: query.byVersion ? key.version : nil
                )

                totals.add(
                    point.value,
                    key: series,
                    start: query.bucket.start(of: point.date)
                )
            }

            return totals.series
        }
    }
}

private struct LifecycleSource {
    let entity: String
    let field: String?
    let isNamed: Bool

    init(name: String) {
        let counted = [
            SessionEntry.recordType,
            CrashEntry.recordType,
            HangEntry.recordType,
            ResourceEntry.recordType,
            ScreenEntry.recordType,
            ConditionEntry.recordType,
        ]

        let marked = [
            Version.installMarker,
            Version.crashMarker,
        ]

        if counted.contains(name) {
            entity = name
            field = nil
        } else if marked.contains(name) {
            entity = FirstSeenEntry.recordType
            field = nil
        } else {
            entity = DailyMetricEntry.recordType
            field = "value"
        }

        isNamed = !counted.contains(name)
    }
}
