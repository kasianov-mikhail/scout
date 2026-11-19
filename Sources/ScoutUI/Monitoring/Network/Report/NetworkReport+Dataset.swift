//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension NetworkReport {
    static func report(starts: [Date], days: Double, bucket: SeriesBucket) -> NetworkReport {
        guard !starts.isEmpty else {
            return NetworkReport(series: [], bucket: bucket)
        }

        var series: [MetricSeries] = []

        for (endpointIndex, endpoint) in NetworkEndpoint.samples.enumerated() {
            for (index, start) in starts.enumerated() {
                let wave = 1 + 0.6 * sin(Double(index + endpointIndex * 3) / 2.4)
                let requests = max(0, Int(Double(endpoint.requests) * days / Double(starts.count) * wave))
                let breakdown = breakdown(total: requests, rate: endpoint.successRate?.value ?? 1)
                let histogram = histogram(total: requests, p99: endpoint.p99 ?? 0.2)

                series += statusSeries(name: endpoint.name, date: start, breakdown: breakdown)
                series += latencySeries(name: endpoint.name, date: start, histogram: histogram)
            }
        }

        return NetworkReport(series: series, bucket: bucket)
    }

    static func hours(in day: Date, now: Date) -> [Date] {
        let start = day.startOfDay
        let end = min(start.addingDay(), now.startOfHour.adding(.hour))
        return start.dates(until: end, by: .hour)
    }

    static func days(in range: Range<Date>, now: Date) -> [Date] {
        let end = min(range.upperBound, now.startOfDay.addingDay())
        return range.lowerBound.startOfDay.dates(until: end, by: .day)
    }

    static func months(in range: Range<Date>) -> [Date] {
        var result: [Date] = []
        var date = range.lowerBound.startOfMonth

        while date < range.upperBound {
            result.append(date)
            date = date.addingMonth()
        }

        return result
    }

    static func breakdown(total: Int, rate: Double) -> StatusBreakdown {
        guard total > 0 else {
            return StatusBreakdown()
        }

        let errors = Int(Double(total) * (1 - rate))
        let redirects = total / 100
        let client = errors * 3 / 4
        let server = errors - client
        let success = max(0, total - errors - redirects)

        var breakdown = StatusBreakdown()
        breakdown.add(count: success, at: 0)
        breakdown.add(count: redirects, at: 1)
        breakdown.add(count: client, at: 2)
        breakdown.add(count: server, at: 3)
        return breakdown
    }

    static func histogram(total: Int, p99: TimeInterval) -> LatencyHistogram {
        var histogram = LatencyHistogram()
        guard total > 0 else {
            return histogram
        }

        let center = LatencyBuckets.boundsMilliseconds.firstIndex { Double($0) / 1_000 >= p99 } ?? LatencyHistogram.bucketCount - 1
        let weights = (0..<LatencyHistogram.bucketCount).map { index in
            max(0, 1 - abs(Double(index - center)) / 5)
        }
        let sum = weights.reduce(0, +)

        guard sum > 0 else {
            histogram.add(count: total, at: center)
            return histogram
        }

        var assigned = 0
        for index in 0..<LatencyHistogram.bucketCount {
            let count = index == LatencyHistogram.bucketCount - 1 ? total - assigned : Int(Double(total) * weights[index] / sum)
            histogram.add(count: count, at: index)
            assigned += count
        }

        return histogram
    }

    static func statusSeries(name: String, date: Date, breakdown: StatusBreakdown) -> [MetricSeries] {
        breakdown.counts.enumerated().compactMap { index, count in
            guard count > 0 else {
                return nil
            }
            return MetricSeries(
                name: name,
                category: StatusBuckets.categories[index],
                points: [MetricSeriesPoint(date: date, value: Double(count))]
            )
        }
    }

    static func latencySeries(name: String, date: Date, histogram: LatencyHistogram) -> [MetricSeries] {
        histogram.counts.enumerated().compactMap { index, count in
            guard count > 0 else {
                return nil
            }
            return MetricSeries(
                name: name,
                category: LatencyBuckets.categories[index],
                points: [MetricSeriesPoint(date: date, value: Double(count))]
            )
        }
    }
}
