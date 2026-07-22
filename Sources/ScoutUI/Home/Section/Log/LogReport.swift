//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct LogReport {
    private let trends: [LogCategory: Trend]

    init(series: [MetricSeries], visits: [DeviceVisit], period: Period) {
        trends = Self.trends(series: series, visits: visits, period: period)
    }

    func trend(for category: LogCategory) -> Trend {
        trends[category] ?? .loading
    }

    private static func trends(series: [MetricSeries], visits: [DeviceVisit], period: Period) -> [LogCategory: Trend] {
        let window = period.previousRange.lowerBound..<period.initialRange.upperBound
        let span = SeriesSpan(series: series, range: window)
        let slices = period.initialRange.slices(count: MiniChartSeries.sliceCount)

        func metricCount(in range: Range<Date>) -> Int {
            SeriesSpan(series: series, range: range).metricCount
        }

        let metrics = Trend(
            count: metricCount(in: period.initialRange),
            previous: metricCount(in: period.previousRange),
            values: slices.map(metricCount)
        )

        let devices = Trend(
            count: visits.devices(in: period.initialRange),
            previous: visits.devices(in: period.previousRange),
            values: slices.map { visits.devices(in: $0) }
        )

        return [
            .events: Trend(
                points: span.points { $0 != CrashEntry.recordType && $0 != HangEntry.recordType }, period: period),
            .crashes: Trend(points: span.points { $0 == CrashEntry.recordType }, period: period),
            .hangs: Trend(points: span.points { $0 == HangEntry.recordType }, period: period),
            .network: Trend(points: span.points(inCategories: Set(StatusBuckets.categories)), period: period),
            .metrics: metrics,
            .devices: devices,
        ]
    }
}
