//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct LogReport {
    let series: [MetricSeries]
    let visits: [DeviceVisit]
    let period: Period

    func summary(for category: LogCategory) -> MetricSummary {
        let span = span

        return switch category {
        case .events:
            MetricSummary(
                points: span.points { $0 != CrashEntry.recordType && $0 != HangEntry.recordType }, period: period)
        case .crashes:
            MetricSummary(points: span.points { $0 == CrashEntry.recordType }, period: period)
        case .hangs:
            MetricSummary(points: span.points { $0 == HangEntry.recordType }, period: period)
        case .network:
            MetricSummary(points: span.points(inCategories: Set(StatusBuckets.categories)), period: period)
        case .metrics:
            metricsSummary
        case .devices:
            devicesSummary
        }
    }

    private var window: Range<Date> {
        period.previousRange.lowerBound..<period.initialRange.upperBound
    }

    private var span: SeriesSpan {
        SeriesSpan(series: series, range: window)
    }

    private var metricsSummary: MetricSummary {
        func count(in range: Range<Date>) -> Int {
            SeriesSpan(series: series, range: range).metricCount
        }

        return MetricSummary(
            count: count(in: period.initialRange),
            previous: count(in: period.previousRange),
            values: slices.map(count)
        )
    }

    private var devicesSummary: MetricSummary {
        MetricSummary(
            count: visits.devices(in: period.initialRange),
            previous: visits.devices(in: period.previousRange),
            values: slices.map { visits.devices(in: $0) }
        )
    }

    private var slices: [Range<Date>] {
        period.initialRange.slices(count: MiniChartSeries.sliceCount)
    }
}
