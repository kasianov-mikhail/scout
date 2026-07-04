//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

struct NetworkReport {
    let distributions: [String: TimerDistribution]
    let statuses: [String: StatusDistribution]

    private let combined: TimerDistribution

    init(distributions: [String: TimerDistribution], statuses: [String: StatusDistribution]) {
        self.distributions = distributions
        self.statuses = statuses

        var merged: [Date: LatencyHistogram] = [:]
        for distribution in distributions.values {
            for (date, histogram) in distribution.histograms {
                merged[date] = merged[date, default: LatencyHistogram()] + histogram
            }
        }
        combined = TimerDistribution(histograms: merged)
    }

    init(series: [MetricSeries]) {
        var latency: [String: [MetricSeries]] = [:]
        var status: [String: [MetricSeries]] = [:]

        for singleSeries in series {
            guard let category = singleSeries.category else { continue }

            if LatencyBuckets.index(of: category) != nil {
                latency[singleSeries.name, default: []].append(singleSeries)
            } else if StatusBuckets.index(of: category) != nil {
                status[singleSeries.name, default: []].append(singleSeries)
            }
        }

        // Latency-only timers count as endpoints only when their name reads
        // like an HTTP request, so generic app timers stay off the screen.
        self.init(
            distributions: latency
                .filter { status.keys.contains($0.key) || NetworkEndpoint.isEndpointName($0.key) }
                .mapValues(TimerDistribution.init),
            statuses: status.mapValues(StatusDistribution.init)
        )
    }

    var isEmpty: Bool {
        statuses.values.allSatisfy(\.isEmpty) && distributions.values.allSatisfy(\.isEmpty)
    }

    func endpoints(in range: Range<Date>) -> [NetworkEndpoint] {
        Set(statuses.keys)
            .union(distributions.keys)
            .map { name in
                let breakdown = statuses[name]?.summary(in: range) ?? StatusBreakdown()
                let requests = breakdown.total > 0 ? breakdown.total : distributions[name]?.total(in: range) ?? 0
                return NetworkEndpoint(
                    name: name,
                    requests: requests,
                    successRate: breakdown.total > 0 ? breakdown.successRate : nil,
                    p99: distributions[name]?.summary(in: range)?.p99
                )
            }
            .sorted { lhs, rhs in
                lhs.requests == rhs.requests ? lhs.name < rhs.name : lhs.requests > rhs.requests
            }
    }

    func summary(in range: Range<Date>) -> StatusBreakdown {
        statuses.values.reduce(StatusBreakdown()) { $0 + $1.summary(in: range) }
    }

    func percentiles(in range: Range<Date>) -> LatencyPercentiles? {
        combined.summary(in: range)
    }

    func trend(in range: Range<Date>, component: Calendar.Component) -> [PercentileTrendPoint] {
        combined.trend(in: range, component: component)
    }

    func requestsPerMinute(in range: Range<Date>, until now: Date = .now) -> Int {
        let end = min(now, range.upperBound)
        let minutes = max(1.0, end.timeIntervalSince(range.lowerBound) / .minute)
        let total = endpoints(in: range).reduce(0) { $0 + $1.requests }
        return Int(Double(total) / minutes)
    }
}

extension NetworkReport {
    static var sample: NetworkReport {
        let statuses: [String: StatusDistribution] = [
            "GET /v1/events": .sample(success: 8_140, redirect: 210, clientError: 52, serverError: 18),
            "POST /v1/metrics": .sample(success: 5_160, clientError: 44, serverError: 6),
            "GET /v1/releases": .sample(success: 3_050, clientError: 80, serverError: 10),
            "POST /v1/crash": .sample(success: 1_040, clientError: 120, serverError: 20),
            "GET /health": .sample(success: 640),
        ]

        return NetworkReport(
            distributions: statuses.mapValues { _ in TimerDistribution.sample },
            statuses: statuses
        )
    }
}
