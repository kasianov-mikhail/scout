//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension DatabaseReader {
    package func metricSeries<T: MetricScalar>(
        _ valueType: T.Type, category: String, reduce: SeriesQuery.Reduce = .sum, in range: Range<Date>
    ) async throws -> [MetricSeries] {
        try await series(
            matching: SeriesQuery(
                category: category,
                values: T.seriesValues,
                bucket: .hour,
                reduce: reduce,
                range: range
            )
        )
    }

    package func metricSeries<T: MetricScalar>(
        _ valueType: T.Type, categories: [String], in range: Range<Date>
    ) async throws -> [MetricSeries] {
        try await withThrowingTaskGroup(of: [MetricSeries].self) { group in
            for category in categories {
                group.addTask {
                    try await self.metricSeries(T.self, category: category, in: range)
                }
            }
            var series: [MetricSeries] = []
            for try await chunk in group {
                series += chunk
            }
            return series
        }
    }
}

package struct SeriesQuery: Sendable {
    package enum Bucket: String, Sendable {
        case hour, day, week
    }

    package enum Source: String, Sendable {
        case event, lifecycle, metric
    }

    package enum Values: String, Sendable {
        case int, double
    }

    package enum Reduce: String, Sendable {
        case sum, last
    }

    package var name: String?
    package var category: String?
    package var values: Values?
    package var bucket: Bucket = .day
    package var byVersion = false
    package var source: Source?
    package var reduce: Reduce = .sum
    package var range: Range<Date>

    package init(
        name: String? = nil, category: String? = nil, values: Values? = nil, bucket: Bucket = .day,
        byVersion: Bool = false, source: Source? = nil, reduce: Reduce = .sum, range: Range<Date>
    ) {
        self.name = name
        self.category = category
        self.values = values
        self.bucket = bucket
        self.byVersion = byVersion
        self.source = source
        self.reduce = reduce
        self.range = range
    }
}

package struct MetricSeries: Decodable, Sendable {
    package let name: String
    package let category: String?
    package let version: String?
    package let points: [MetricSeriesPoint]

    package init(name: String, category: String?, version: String? = nil, points: [MetricSeriesPoint]) {
        self.name = name
        self.category = category
        self.version = version
        self.points = points
    }
}

package struct MetricSeriesPoint: Decodable, Sendable {
    package let date: Int64
    package let value: MetricValue

    package init(date: Int64, value: MetricValue) {
        self.date = date
        self.value = value
    }
}

package enum MetricValue: Decodable, Equatable, Sendable {
    case int(Int)
    case double(Double)

    private enum CodingKeys: String, CodingKey {
        case int, double
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let value = try container.decodeIfPresent(Int.self, forKey: .int) {
            self = .int(value)
        } else if let value = try container.decodeIfPresent(Double.self, forKey: .double) {
            self = .double(value)
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unknown metric value type"
                )
            )
        }
    }
}

extension MetricValue {
    package var doubleValue: Double {
        switch self {
        case .int(let value):
            Double(value)
        case .double(let value):
            value
        }
    }

    package var intValue: Int {
        switch self {
        case .int(let value):
            value
        case .double(let value):
            Int(value.rounded())
        }
    }
}
