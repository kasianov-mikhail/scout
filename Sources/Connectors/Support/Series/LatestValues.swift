//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

package struct LatestValues {
    private var latest: [SeriesKey: [Date: Reading]] = [:]

    package init() {}

    package mutating func add(_ value: Double, key: SeriesKey, date: Date, start: Date) {
        if let existing = latest[key]?[start], existing.date >= date {
            return
        }

        latest[key, default: [:]][start] = Reading(date: date, value: value)
    }

    package var series: [MetricSeries] {
        latest.mapValues { readings in
            readings.mapValues(\.value)
        }
        .series
    }

    private struct Reading {
        let date: Date
        let value: Double
    }
}
