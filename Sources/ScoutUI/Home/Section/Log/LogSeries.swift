//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct LogSeries {
    let series: [MetricSeries]
    let visits: [DeviceVisit]
    let period: Period

    var report: [LogCategory: Trend] {
        let window = period.previousRange.lowerBound..<period.initialRange.upperBound
        let span = SeriesSpan(series: series, range: window)
        let slices = period.initialRange.slices(count: MiniChartSeries.sliceCount)

        let metrics = Trend(
            count: count(in: period.initialRange),
            previous: count(in: period.previousRange),
            values: slices.map(count)
        )

        let devices = Trend(
            count: visits.devices(in: period.initialRange),
            previous: visits.devices(in: period.previousRange),
            values: slices.map { visits.devices(in: $0) }
        )

        let incidents: Set = [CrashEntry.recordType, HangEntry.recordType]

        return [
            .events: trend(span.points { !incidents.contains($0) }),
            .crashes: trend(span.points { $0 == CrashEntry.recordType }),
            .hangs: trend(span.points { $0 == HangEntry.recordType }),
            .network: trend(span.points(inCategories: Set(StatusBuckets.categories))),
            .metrics: metrics,
            .devices: devices,
        ]
    }

    private func count(in range: Range<Date>) -> Int {
        SeriesSpan(series: series, range: range).metricCount
    }

    private func trend(_ points: [ChartPoint<Int>]) -> Trend {
        .total(points: points, period: period)
    }
}
