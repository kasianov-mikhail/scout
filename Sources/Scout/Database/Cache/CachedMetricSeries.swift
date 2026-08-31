//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

enum CachedMetricSeries {
    static func fingerprint(scope: String, query: SeriesQuery) -> String {
        [
            scope, "series",
            query.name ?? "*",
            query.category ?? "*",
            query.values?.rawValue ?? "*",
            query.bucket.rawValue,
            query.byVersion ? "version" : "*",
            query.source?.rawValue ?? "*",
            query.reduce.rawValue,
        ]
        .joined(separator: "|")
    }

    static func records(from series: [MetricSeries]) -> [Record] {
        series.flatMap { series in
            series.points.map { point in
                var record = Record(recordType: "MetricSeriesPoint", recordID: UUID().uuidString)
                record.fields["date"] = .date(Date(millisecondsSince1970: point.date))
                record.fields["name"] = .string(series.name)
                record.fields["category"] = series.category.map(RecordValue.string)
                record.fields["app_version"] = series.version.map(RecordValue.string)
                record.fields["value"] = recordValue(point.value)
                return record
            }
        }
    }

    static func series(cached: [Record], fetched: [MetricSeries]) -> [MetricSeries] {
        var groups = SeriesGroups()

        for record in cached {
            guard case .date(let date)? = record.fields["date"] else {
                continue
            }
            guard case .string(let name)? = record.fields["name"] else {
                continue
            }
            guard let value = metricValue(record.fields["value"]) else {
                continue
            }

            let category: String? =
                if case .string(let category)? = record.fields["category"] { category } else { nil }
            let version: String? =
                if case .string(let version)? = record.fields["app_version"] { version } else { nil }
            let key = SeriesKey(name: name, category: category, version: version)
            groups.append(MetricSeriesPoint(date: date.millisecondsSince1970, value: value), to: key)
        }

        for series in fetched {
            groups.append(series)
        }

        return groups.series
    }

    private static func recordValue(_ value: MetricValue) -> RecordValue {
        switch value {
        case .int(let value):
            .int(Int64(value))
        case .double(let value):
            .double(value)
        }
    }

    private static func metricValue(_ value: RecordValue?) -> MetricValue? {
        switch value {
        case .int(let value):
            .int(Int(value))
        case .double(let value):
            .double(value)
        default:
            nil
        }
    }
}

struct SeriesKey: Hashable, Comparable {
    let name: String
    let category: String?
    let version: String?

    static func < (lhs: Self, rhs: Self) -> Bool {
        (lhs.name, lhs.category ?? "", lhs.version ?? "") < (rhs.name, rhs.category ?? "", rhs.version ?? "")
    }
}

struct SeriesGroups {
    private var points: [SeriesKey: [MetricSeriesPoint]] = [:]

    mutating func append(_ point: MetricSeriesPoint, to key: SeriesKey) {
        points[key, default: []].append(point)
    }

    mutating func append(_ series: MetricSeries) {
        let key = SeriesKey(
            name: series.name,
            category: series.category,
            version: series.version
        )
        points[key, default: []] += series.points
    }

    var series: [MetricSeries] {
        points.sorted(by: \.key).map { key, points in
            MetricSeries(
                name: key.name,
                category: key.category,
                version: key.version,
                points: points.sorted { $0.date < $1.date }
            )
        }
    }
}

extension Sequence {
    fileprivate func sorted<Value: Comparable>(by keyPath: KeyPath<Element, Value>) -> [Element] {
        sorted { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
    }
}
