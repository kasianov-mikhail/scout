//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct MetricTimeline {
    let points: [ChartPoint<Double>]
}

extension MetricTimeline {
    func buckets(range: MetricRange, now: Date, fold: ChartFold) -> [MetricBucket] {
        range.buckets(now: now).map { bucket in
            let isFuture = range.isFuture(date: bucket.lowerBound, now: now)
            let previous = range.shifted(bucket)

            return MetricBucket(
                date: bucket.lowerBound,
                value: isFuture ? nil : fold.value(points: points.filter { bucket.contains($0.date) }),
                previous: isFuture ? nil : fold.value(points: points.filter { previous.contains($0.date) }),
                isFuture: isFuture,
                isCurrent: range.isCurrent(date: bucket.lowerBound, now: now)
            )
        }
    }

    func containsData(range: MetricRange, now: Date) -> Bool {
        let window = range.elapsedRange(now: now)
        return points.contains { window.contains($0.date) }
    }

    func summary(range: MetricRange, now: Date, format: MetricValueFormat) -> MetricSummary {
        MetricSummary(
            total: points.total(in: range.elapsedRange(now: now)),
            previous: points.total(in: range.elapsedPreviousRange(now: now)),
            range: range,
            format: format
        )
    }

    func gaugeSummary(range: MetricRange, now: Date, format: MetricValueFormat) -> MetricSummary {
        let window = range.elapsedRange(now: now)
        let windowPoints = points.filter { window.contains($0.date) }

        return MetricSummary(
            latest: windowPoints.max { $0.date < $1.date },
            peak: windowPoints.max { $0.value < $1.value },
            range: range,
            format: format
        )
    }
}
