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

    let combined: TimerDistribution
    let bucket: SeriesBucket

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
