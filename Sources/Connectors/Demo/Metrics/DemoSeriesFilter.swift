//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ConnectorSupport
import Foundation
import Scout

struct DemoSeriesFilter {
    let source: DemoSample.Source
    var name: String?
    var category: String?
    var values: MetricSeriesQuery.Values?
    var byVersion = false
    var reduce = MetricSeriesQuery.Reduce.sum
    let bucket: SeriesBucket
    let range: Range<Date>
}

extension DemoSeriesFilter {
    func series(in samples: [DemoSample]) -> [MetricSeries] {
        let matched = samples.filter(matches)
        let ints = folded(matched.filter { $0.values == .int })
        let doubles = folded(matched.filter { $0.values == .double })

        return MetricSeries.merge(ints: ints, doubles: doubles, values: values)
    }

    private func matches(_ sample: DemoSample) -> Bool {
        guard source == sample.source else {
            return false
        }
        guard name == nil || name == sample.name else {
            return false
        }
        guard category == nil || category == sample.category else {
            return false
        }
        guard values == nil || values == sample.values else {
            return false
        }
        guard !byVersion || sample.version != nil else {
            return false
        }
        return range.contains(sample.date)
    }

    private func folded(_ samples: [DemoSample]) -> [MetricSeries] {
        switch reduce {
        case .sum:
            var totals = SeriesTotals()

            for sample in samples {
                totals.add(
                    sample.value,
                    key: key(for: sample),
                    start: bucket.start(of: sample.date)
                )
            }

            return totals.series

        case .last:
            var latest = LatestValues()

            for sample in samples {
                latest.add(
                    sample.value,
                    key: key(for: sample),
                    date: sample.date,
                    start: bucket.start(of: sample.date)
                )
            }

            return latest.series
        }
    }

    private func key(for sample: DemoSample) -> SeriesKey {
        SeriesKey(
            name: sample.name,
            category: sample.category,
            version: byVersion ? sample.version : nil
        )
    }
}
