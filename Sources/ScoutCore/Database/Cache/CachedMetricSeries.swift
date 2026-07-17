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
            query.values ?? "*",
            query.bucket.rawValue,
            query.byVersion ? "version" : "*",
        ].joined(separator: "|")
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
        var points: [SeriesKey: [MetricSeriesPoint]] = [:]

        for record in cached {
            guard case .date(let date)? = record.fields["date"] else { continue }
            guard case .string(let name)? = record.fields["name"] else { continue }
            guard let value = metricValue(record.fields["value"]) else { continue }

            let category: String? =
                if case .string(let category)? = record.fields["category"] { category } else { nil }
            let version: String? =
                if case .string(let version)? = record.fields["app_version"] { version } else { nil }
            let point = MetricSeriesPoint(date: date.millisecondsSince1970, value: value)
            points[SeriesKey(name: name, category: category, version: version), default: []].append(point)
        }

        for series in fetched {
            points[SeriesKey(name: series.name, category: series.category, version: series.version), default: []] +=
                series.points
        }

        return
            points
            .sorted {
                ($0.key.name, $0.key.category ?? "", $0.key.version ?? "")
                    < ($1.key.name, $1.key.category ?? "", $1.key.version ?? "")
            }
            .map { key, points in
                MetricSeries(
                    name: key.name,
                    category: key.category,
                    version: key.version,
                    points: points.sorted { $0.date < $1.date }
                )
            }
    }

    private struct SeriesKey: Hashable {
        let name: String
        let category: String?
        let version: String?
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
