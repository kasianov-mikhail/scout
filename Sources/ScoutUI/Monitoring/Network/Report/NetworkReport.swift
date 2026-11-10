//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout

struct NetworkReport {
    let distributions: [String: TimerDistribution]
    let statuses: [String: StatusDistribution]

    private let combined: TimerDistribution
    private let bucket: SeriesBucket

    init(distributions: [String: TimerDistribution], statuses: [String: StatusDistribution], bucket: SeriesBucket) {
        self.distributions = distributions
        self.statuses = statuses
        self.bucket = bucket

        var merged: [Date: LatencyHistogram] = [:]
        for distribution in distributions.values {
            for (date, histogram) in distribution.histograms {
                merged[date] = merged[date, default: LatencyHistogram()] + histogram
            }
        }
        self.combined = TimerDistribution(histograms: merged)
    }

    init(series: [MetricSeries], bucket: SeriesBucket) {
        var latency: [String: [MetricSeries]] = [:]
        var status: [String: [MetricSeries]] = [:]

        for singleSeries in series {
            guard let category = singleSeries.category else {
                continue
            }

            if LatencyBuckets.index(of: category) != nil {
                latency[singleSeries.name, default: []].append(singleSeries)
            } else if StatusBuckets.index(of: category) != nil {
                status[singleSeries.name, default: []].append(singleSeries)
            }
        }

        self.init(
            distributions:
                latency
                .filter { status.keys.contains($0.key) || NetworkEndpoint.isEndpointName($0.key) }
                .mapValues(TimerDistribution.init),
            statuses: status.mapValues(StatusDistribution.init),
            bucket: bucket
        )
    }
}

extension NetworkReport {
    var isEmpty: Bool {
        statuses.values.allSatisfy(\.isEmpty) && distributions.values.allSatisfy(\.isEmpty)
    }

    func endpoints(in range: Range<Date>) -> [NetworkEndpoint] {
        Set(statuses.keys)
            .union(distributions.keys)
            .compactMap { name in
                endpoint(name: name, range: range)
            }
            .sorted { lhs, rhs in
                lhs.requests == rhs.requests ? lhs.name < rhs.name : lhs.requests > rhs.requests
            }
    }

    func endpoint(name: String, range: Range<Date>) -> NetworkEndpoint? {
        guard statuses[name] != nil || distributions[name] != nil else {
            return nil
        }

        let breakdown = statusBreakdown(name: name, range: range)
        let histogram = distributions[name]?.histogram(in: range, bucket: bucket)
        let requests = breakdown.total > 0 ? breakdown.total : histogram?.total ?? 0

        return NetworkEndpoint(
            name: name,
            requests: requests,
            successRate: breakdown.total > 0 ? breakdown.successRate : nil,
            p99: histogram?.percentile(0.99)
        )
    }

    func summary(in range: Range<Date>) -> NetworkSummary {
        let endpoints = endpoints(in: range)
        let breakdown = statusBreakdown(range: range)

        return NetworkSummary(
            requests: endpoints.reduce(0) { $0 + $1.requests },
            successRate: breakdown.total > 0 ? breakdown.successRate : nil,
            p99: combined.summary(in: range, bucket: bucket)?.p99,
            endpoints: endpoints.count
        )
    }

    func statusBreakdown(range: Range<Date>) -> StatusBreakdown {
        statuses.values.reduce(StatusBreakdown()) { $0 + $1.summary(in: range, bucket: bucket) }
    }

    func statusBreakdown(name: String, range: Range<Date>) -> StatusBreakdown {
        statuses[name]?.summary(in: range, bucket: bucket) ?? StatusBreakdown()
    }

    func histogram(name: String, range: Range<Date>) -> LatencyHistogram? {
        distributions[name]?.histogram(in: range, bucket: bucket)
    }

    func percentiles(in range: Range<Date>) -> Percentiles? {
        combined.summary(in: range, bucket: bucket)
    }

    func percentiles(name: String, range: Range<Date>) -> Percentiles? {
        distributions[name]?.summary(in: range, bucket: bucket)
    }

    func rows(name: String, range: Range<Date>, component: Calendar.Component, now: Date = .now) -> [NetworkLedgerRow] {
        let starts = bucketStarts(range: range, component: component, now: now)

        return starts.map { start in
            let lower = max(start, range.lowerBound)
            let upper = min(bucketEnd(start, component: component), range.upperBound)
            let interval = lower..<upper
            let breakdown = statusBreakdown(name: name, range: interval)
            let histogram = distributions[name]?.histogram(in: interval, bucket: bucket)
            let requests = breakdown.total > 0 ? breakdown.total : histogram?.total ?? 0

            return NetworkLedgerRow(
                date: start,
                requests: requests,
                successRate: breakdown.total > 0 ? breakdown.successRate : nil,
                p99: histogram?.percentile(0.99),
                isCurrent: start == bucketStart(now, component: component)
            )
        }
        .sorted { $0.date > $1.date }
    }
}

extension NetworkReport {
    private func bucketStarts(range: Range<Date>, component: Calendar.Component, now: Date) -> [Date] {
        var starts: [Date] = []
        var date = bucketStart(range.lowerBound, component: component)
        let limit = min(range.upperBound, now.startOfHour.adding(.hour))

        while date < limit {
            starts.append(date)
            date = bucketEnd(date, component: component)
        }

        return starts
    }

    private func bucketStart(_ date: Date, component: Calendar.Component) -> Date {
        Calendar.utc.dateInterval(of: component, for: date)?.start ?? date
    }

    private func bucketEnd(_ date: Date, component: Calendar.Component) -> Date {
        Calendar.utc.dateInterval(of: component, for: date)?.end ?? date
    }
}
