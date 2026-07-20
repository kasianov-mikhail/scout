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

    func total(in range: Range<Date>) -> Int {
        histogram(in: range).total
    }

    func summary(in range: Range<Date>) -> Percentiles? {
        let combined = histogram(in: range)

        guard let p50 = combined.percentile(0.5),
            let p90 = combined.percentile(0.9),
            let p99 = combined.percentile(0.99)
        else {
            return nil
        }

        return Percentiles(p50: p50, p90: p90, p99: p99)
    }

    func trend(in range: Range<Date>, component: Calendar.Component) -> [PercentileTrendPoint] {
        var result: [PercentileTrendPoint] = []
        var date = range.upperBound
        var steps = 0

        while date > range.lowerBound {
            steps -= 1
            let newDate = range.upperBound.adding(component, value: steps)

            if let p99 = histogram(in: newDate..<date).percentile(0.99) {
                result.append(PercentileTrendPoint(date: newDate, p99: p99))
            }

            date = newDate
        }

        return result.reversed()
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
