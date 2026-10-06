//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

package struct SeriesTotals {
    private var buckets: [SeriesKey: [Date: Double]] = [:]

    package init() {}

    package mutating func add(_ value: Double, key: SeriesKey, start: Date) {
        buckets[key, default: [:]][start, default: 0] += value
    }

    package var series: [MetricSeries] {
        buckets.mapValues { totals in
            totals.filter { $0.value != 0 }
        }
        .series
    }
}

extension [SeriesKey: [Date: Double]] {
    var series: [MetricSeries] {
        map { key, buckets in
            let points = buckets.sorted {
                $0.key < $1.key
            }
            .map {
                MetricSeriesPoint(
                    date: $0.key,
                    value: $0.value
                )
            }

            return MetricSeries(
                name: key.name,
                category: key.category,
                version: key.version,
                points: points
            )
        }
        .nonEmptySorted
    }
}
