//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

struct TimerDistribution: Equatable {
    let histograms: [Date: LatencyHistogram]

    init(histograms: [Date: LatencyHistogram]) {
        self.histograms = histograms
    }

    init(series: [MetricSeries]) {
        var histograms: [Date: LatencyHistogram] = [:]

        for singleSeries in series {
            guard let category = singleSeries.category else { continue }
            guard let index = LatencyBuckets.index(of: category) else { continue }

            for point in singleSeries.points {
                let date = Date(millisecondsSince1970: point.date)
                var histogram = histograms[date, default: LatencyHistogram()]
                histogram.add(count: Int(point.value.doubleValue), at: index)
                histograms[date] = histogram
            }
        }

        self.histograms = histograms
    }

    var isEmpty: Bool {
        histograms.values.allSatisfy { $0.total == 0 }
    }

    func summary(in range: Range<Date>) -> LatencyPercentiles? {
        let combined = histograms
            .filter { range.contains($0.key) }
            .values
            .reduce(LatencyHistogram(), +)

        guard let p50 = combined.percentile(0.5),
            let p90 = combined.percentile(0.9),
            let p99 = combined.percentile(0.99)
        else {
            return nil
        }

        return LatencyPercentiles(p50: p50, p90: p90, p99: p99)
    }

    func trend(in range: Range<Date>, component: Calendar.Component) -> [PercentileTrendPoint] {
        var result: [PercentileTrendPoint] = []
        var date = range.upperBound
        var steps = 0

        while date > range.lowerBound {
            steps -= 1
            let newDate = range.upperBound.adding(component, value: steps)
            let combined = histograms
                .filter { newDate..<date ~= $0.key }
                .values
                .reduce(LatencyHistogram(), +)

            if let p99 = combined.percentile(0.99) {
                result.append(PercentileTrendPoint(date: newDate, p99: p99))
            }

            date = newDate
        }

        return result.reversed()
    }
}

extension TimerDistribution {
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
