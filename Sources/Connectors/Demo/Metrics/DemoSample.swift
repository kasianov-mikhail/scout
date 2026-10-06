//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct DemoSample {
    enum Source {
        case event, lifecycle, metric
    }

    let name: String
    let category: String?
    let version: String?
    let source: Source
    let date: Date
    let value: MetricValue

    init(name: String, category: String? = nil, version: String? = nil, source: Source, date: Date, value: MetricValue = .int(1)) {
        self.name = name
        self.category = category
        self.version = version
        self.source = source
        self.date = date
        self.value = value
    }
}

extension [DemoSample] {
    func series(matching query: DemoSeriesFilter) -> [MetricSeries] {
        let matched = filter { $0.matches(query) }

        return [MetricSeries](
            ints: matched.filter(\.value.isInt).folded(query, values: .int),
            doubles: matched.filter { !$0.value.isInt }.folded(query, values: .double),
            values: query.values
        )
        .nonEmptySorted
    }

    private func folded(_ query: DemoSeriesFilter, values: MetricSeriesQuery.Values) -> [MetricSeries] {
        switch query.reduce {
        case .sum:
            var totals = SeriesTotals()

            for sample in self {
                totals.add(sample.value.doubleValue, key: sample.key(query), date: sample.date, bucket: query.bucket)
            }

            return totals.series(values: values)

        case .last:
            var latest = LatestValues()

            for sample in self {
                latest.add(sample.value.doubleValue, key: sample.key(query), date: sample.date, bucket: query.bucket)
            }

            return latest.series(values: values)
        }
    }
}

extension DemoSample {
    fileprivate func key(_ query: DemoSeriesFilter) -> SeriesKey {
        SeriesKey(name: name, category: category, version: query.byVersion ? version : nil)
    }

    fileprivate func matches(_ query: DemoSeriesFilter) -> Bool {
        guard query.source == source else {
            return false
        }
        guard query.name == nil || query.name == name else {
            return false
        }
        guard query.category == nil || query.category == category else {
            return false
        }
        guard query.values == nil || query.values == (value.isInt ? .int : .double) else {
            return false
        }
        return query.range.contains(date)
    }
}

extension MetricValue {
    fileprivate var isInt: Bool {
        if case .int = self { true } else { false }
    }
}

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
    init(query: EventSeriesQuery) {
        self.init(source: .event, name: query.name, bucket: query.bucket, range: query.range)
    }

    init(query: LifecycleSeriesQuery) {
        self.init(source: .lifecycle, name: query.counter.name, byVersion: query.byVersion, bucket: query.bucket, range: query.range)
    }

    init(query: MetricSeriesQuery) {
        self.init(
            source: .metric,
            name: query.name,
            category: query.category,
            values: query.values,
            reduce: query.reduce,
            bucket: query.bucket,
            range: query.range
        )
    }
}
