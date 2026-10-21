//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

package struct SeriesPeaks {
    private var buckets: [SeriesKey: [Date: Double]] = [:]

    package init() {}

    package mutating func add(_ value: Double, key: SeriesKey, start: Date) {
        let peak = buckets[key]?[start].map { max($0, value) } ?? value
        buckets[key, default: [:]][start] = peak
    }

    package var series: [MetricSeries] {
        buckets.series
    }
}
