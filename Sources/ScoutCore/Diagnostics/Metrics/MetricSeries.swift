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

public struct SeriesQuery: Sendable {
    public enum Bucket: String, Sendable {
        case hour, day, week
    }

    public var name: String?
    public var category: String?
    public var values: String?
    public var bucket: Bucket = .day
    public var byVersion = false
    public var range: Range<Date>

    public init(
        name: String? = nil, category: String? = nil, values: String? = nil, bucket: Bucket = .day,
        byVersion: Bool = false, range: Range<Date>
    ) {
        self.name = name
        self.category = category
        self.values = values
        self.bucket = bucket
        self.byVersion = byVersion
        self.range = range
    }
}

public struct MetricSeries: Decodable, Sendable {
    public let name: String
    public let category: String?
    public let version: String?
    public let points: [MetricSeriesPoint]

    public init(name: String, category: String?, version: String? = nil, points: [MetricSeriesPoint]) {
        self.name = name
        self.category = category
        self.version = version
        self.points = points
    }
}

public struct MetricSeriesPoint: Decodable, Sendable {
    public let date: Int64
    public let value: MetricValue

    public init(date: Int64, value: MetricValue) {
        self.date = date
        self.value = value
    }
}

public enum MetricValue: Decodable, Equatable, Sendable {
    case int(Int)
    case double(Double)

    private enum CodingKeys: String, CodingKey {
        case int, double
    }

    public init(from decoder: any Decoder) throws {
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
    public var doubleValue: Double {
        switch self {
        case .int(let value):
            Double(value)
        case .double(let value):
            value
        }
    }

    public var intValue: Int {
        switch self {
        case .int(let value):
            value
        case .double(let value):
            Int(value.rounded())
        }
    }
}
