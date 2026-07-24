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

        func point(hour: Int, value: MetricValue) -> MetricSeriesPoint {
            MetricSeriesPoint(
                date: date.addingTimeInterval(TimeInterval(hour) * .hour).millisecondsSince1970,
                value: value
            )
        }

        return [
            MetricSeries(
                name: EventEntry.recordType,
                category: nil,
                points: [point(hour: 0, value: .int(48))]
            ),
            MetricSeries(
                name: CrashEntry.recordType,
                category: nil,
                points: [point(hour: 1, value: .int(3))]
            ),
            MetricSeries(
                name: HangEntry.recordType,
                category: nil,
                points: [point(hour: 4, value: .int(6))]
            ),
            MetricSeries(
                name: "api_calls",
                category: Telemetry.Export.counter.rawValue,
                points: [point(hour: 2, value: .int(140))]
            ),
            MetricSeries(
                name: "cache_hit_rate",
                category: Telemetry.Export.floatingCounter.rawValue,
                points: [point(hour: 3, value: .double(91.5))]
            ),
        ]
    }
}
