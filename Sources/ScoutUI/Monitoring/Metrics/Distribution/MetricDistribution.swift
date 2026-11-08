//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout

typealias TimerDistribution = MetricDistribution<LatencyHistogram>
typealias RecorderDistribution = MetricDistribution<RecorderHistogram>

struct Percentiles: Equatable {
    let p50: Double
    let p90: Double
    let p99: Double
}

struct MetricDistribution<H: QuantileHistogram>: Equatable {
    let histograms: [Date: H]

    init(histograms: [Date: H]) {
        self.histograms = histograms
    }

    init(series: [MetricSeries]) {
        self.init(histograms: H.buckets(from: series))
    }

    var isEmpty: Bool {
        histograms.values.allSatisfy { $0.total == 0 }
    }

    func histogram(in range: Range<Date>) -> H {
        histograms
            .filter { range.contains($0.key) }
            .values
            .reduce(H(), +)
    }

    func summary(in range: Range<Date>) -> Percentiles? {
        let combined = histogram(in: range)

        guard let p50 = combined.percentile(0.5), let p90 = combined.percentile(0.9), let p99 = combined.percentile(0.99) else {
            return nil
        }

        return Percentiles(p50: p50, p90: p90, p99: p99)
    }
}

extension MetricDistribution {
    func buckets(range: MetricRange, quantile: MetricQuantile, now: Date) -> [MetricBucket] {
        range.buckets(now: now).map { bucket in
            let isFuture = range.isFuture(date: bucket.lowerBound, now: now)
            let previous = range.shifted(bucket)

            return MetricBucket(
                date: bucket.lowerBound,
                value: isFuture ? nil : histogram(in: bucket).percentile(quantile.value),
                previous: isFuture ? nil : histogram(in: previous).percentile(quantile.value),
                isFuture: isFuture,
                isCurrent: range.isCurrent(date: bucket.lowerBound, now: now)
            )
        }
    }

    func histogram(range: MetricRange, now: Date) -> H {
        histogram(in: range.elapsedRange(now: now))
    }

    func summary(range: MetricRange, now: Date) -> Percentiles? {
        summary(in: range.elapsedRange(now: now))
    }

    func previousSummary(range: MetricRange, now: Date) -> Percentiles? {
        summary(in: range.elapsedPreviousRange(now: now))
    }
}

extension Percentiles {
    static var sample: Percentiles {
        Percentiles(p50: 0.081, p90: 0.42, p99: 3.8)
    }
}

extension MetricDistribution where H == LatencyHistogram {
    static var sample: TimerDistribution {
        let start = Calendar.current.startOfDay(for: .now)
        var histograms: [Date: LatencyHistogram] = [:]

        for hour in 0..<24 {
            var histogram = LatencyHistogram()
            for (offset, weight) in [2, 8, 21, 34, 27, 13, 5, 3, 2, 1].enumerated() {
                histogram.add(count: weight * (1 + hour % 5), at: offset + 4)
            }
            histograms[start.addingTimeInterval(TimeInterval(hour) * .hour)] = histogram
        }

        return TimerDistribution(histograms: histograms)
    }
}

extension MetricDistribution where H == RecorderHistogram {
    static var sample: RecorderDistribution {
        let start = Calendar.current.startOfDay(for: .now)
        var histograms: [Date: RecorderHistogram] = [:]

        for hour in 0..<24 {
            var histogram = RecorderHistogram()
            for (offset, weight) in [2, 8, 21, 34, 27, 13, 5, 3, 2, 1].enumerated() {
                histogram.add(count: weight * (1 + hour % 5), at: offset + 4)
            }
            histograms[start.addingTimeInterval(TimeInterval(hour) * .hour)] = histogram
        }

        return RecorderDistribution(histograms: histograms)
    }
}
