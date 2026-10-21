//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct LogSnapshot {
    let series: [MetricSeries]
    let deviceCounts: [Int]
}

extension LogSnapshot {
    static func sample(for period: Period) -> LogSnapshot {
        LogSnapshot(series: MetricSeries.samples(for: period), deviceCounts: [9, 7, 2, 3, 5, 4, 6, 3, 4])
    }
}

extension Period {
    var deviceRanges: [Range<Date>] {
        [initialRange, previousRange] + initialRange.slices(count: MiniChartSeries.sliceCount)
    }
}

struct LogSeries {
    let snapshot: LogSnapshot
    let period: Period

    var report: [LogCategory: Trend] {
        let window = period.previousRange.lowerBound..<period.initialRange.upperBound
        let span = SeriesSpan(series: snapshot.series, range: window)
        let slices = period.initialRange.slices(count: MiniChartSeries.sliceCount)

        let metrics = Trend(
            count: count(in: period.initialRange),
            previous: count(in: period.previousRange),
            values: slices.map(count)
        )

        let incidents: Set = [CrashEntry.recordType, HangEntry.recordType]

        return [
            .events: Trend(total: span.points { !incidents.contains($0) }, period: period),
            .crashes: Trend(total: span.points { $0 == CrashEntry.recordType }, period: period),
            .hangs: Trend(total: span.points { $0 == HangEntry.recordType }, period: period),
            .network: Trend(total: span.points(inCategories: Set(StatusBuckets.categories)), period: period),
            .metrics: metrics,
            .devices: deviceTrend,
        ]
    }

    private var deviceTrend: Trend {
        let expected = period.deviceRanges.count
        let counts = snapshot.deviceCounts.count == expected ? snapshot.deviceCounts : Array(repeating: 0, count: expected)

        return Trend(count: counts[0], previous: counts[1], values: Array(counts.dropFirst(2)))
    }

    private func count(in range: Range<Date>) -> Int {
        SeriesSpan(series: snapshot.series, range: range).metricCount
    }
}
