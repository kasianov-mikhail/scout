//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension MetricSeries {
    static func samples(for period: Period) -> [MetricSeries] {
        let date = period.initialRange.lowerBound

        func point(hour: Int, value: Double) -> MetricSeriesPoint {
            MetricSeriesPoint(
                date: date.addingTimeInterval(TimeInterval(hour) * .hour),
                value: value
            )
        }

        return [
            MetricSeries(
                name: EventEntry.recordType,
                category: nil,
                points: [point(hour: 0, value: 48)]
            ),
            MetricSeries(
                name: CrashEntry.recordType,
                category: nil,
                points: [point(hour: 1, value: 3)]
            ),
            MetricSeries(
                name: HangEntry.recordType,
                category: nil,
                points: [point(hour: 4, value: 6)]
            ),
            MetricSeries(
                name: "api_calls",
                category: Telemetry.Export.counter.rawValue,
                points: [point(hour: 2, value: 140)]
            ),
            MetricSeries(
                name: "cache_hit_rate",
                category: Telemetry.Export.floatingCounter.rawValue,
                points: [point(hour: 3, value: 91.5)]
            ),
        ]
    }
}
