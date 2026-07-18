//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension DatabaseReader {
    package func metricSeries<T: MetricScalar>(_ valueType: T.Type, category: String, in range: Range<Date>)
        async throws
        -> [MetricSeries]
    {
        try await series(
            matching: SeriesQuery(category: category, values: T.seriesValues, bucket: .hour, range: range)
        )
    }
}

package struct SeriesQuery: Sendable {
    package enum Bucket: String, Sendable {
        case hour, day, week
    }

    // Picks the namespace a name resolves against so a custom event and a
    // built-in counter can share a name (e.g. "Session") without one shadowing
    // the other. When absent the backend infers the namespace from the name,
    // preserving the original string-guess behavior for existing callers.
    package enum Source: String, Sendable {
        case event, lifecycle, metric
    }

    package var name: String?
    package var category: String?
    package var values: String?
    package var bucket: Bucket = .day
    package var byVersion = false
    package var source: Source?
    package var range: Range<Date>

    package init(
        name: String? = nil, category: String? = nil, values: String? = nil, bucket: Bucket = .day,
        byVersion: Bool = false, source: Source? = nil, range: Range<Date>
    ) {
        self.name = name
        self.category = category
        self.values = values
        self.bucket = bucket
        self.byVersion = byVersion
        self.source = source
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
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unknown metric value type"))
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
