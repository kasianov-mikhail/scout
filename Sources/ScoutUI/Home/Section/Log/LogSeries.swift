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
    func deviceRanges(now: Date) -> [Range<Date>] {
        [elapsedRange(now: now), elapsedPreviousRange(now: now)] + trailingRange(now: now).slices(count: MiniChartSeries.sliceCount)
    }
}

struct LogSeries {
    let snapshot: LogSnapshot
    let period: Period
    let now: Date

    var report: [LogCategory: Trend] {
        let window = period.previousRange.lowerBound..<period.initialRange.upperBound
        let span = SeriesSpan(series: snapshot.series, range: window)
        let slices = period.trailingRange(now: now).slices(count: MiniChartSeries.sliceCount)

        let metrics = Trend(
            count: count(in: period.elapsedRange(now: now)),
            previous: count(in: period.elapsedPreviousRange(now: now)),
            values: slices.map(count)
        )

        let incidents: Set = [Crash.recordType, Hang.recordType]

        return [
            .events: Trend(total: span.points { !incidents.contains($0) }, period: period, now: now),
            .crashes: Trend(total: span.points { $0 == Crash.recordType }, period: period, now: now),
            .hangs: Trend(total: span.points { $0 == Hang.recordType }, period: period, now: now),
            .network: Trend(total: span.points(inCategories: Set(StatusBuckets.categories)), period: period, now: now),
            .metrics: metrics,
            .devices: deviceTrend,
        ]
    }

    private var deviceTrend: Trend {
        let expected = period.deviceRanges(now: now).count
        let counts = snapshot.deviceCounts.count == expected ? snapshot.deviceCounts : Array(repeating: 0, count: expected)

        return Trend(count: counts[0], previous: counts[1], values: Array(counts.dropFirst(2)))
    }

    private func count(in range: Range<Date>) -> Int {
        SeriesSpan(series: snapshot.series, range: range).metricCount
    }
}
