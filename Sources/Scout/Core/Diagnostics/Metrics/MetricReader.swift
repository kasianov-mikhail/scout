//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

protocol MetricReader: RecordReader {
    func series(matching query: SeriesQuery) async throws -> [MetricSeries]
}

extension MetricReader {
    func metricSeries<T: SeriesScalar>(_ valueType: T.Type, category: String, in range: Range<Date>) async throws
        -> [MetricSeries]
    {
        try await series(
            matching: SeriesQuery(category: category, values: T.seriesValues, bucket: .hour, range: range)
        )
    }
}

struct SeriesQuery {
    enum Bucket: String {
        case hour, day, week
    }

    var name: String?
    var category: String?
    var values: String?
    var bucket: Bucket = .day
    var byVersion = false
    let range: Range<Date>
}

struct MetricSeries: Decodable {
    let name: String
    let category: String?
    let version: String?
    let points: [MetricSeriesPoint]

    init(name: String, category: String?, version: String? = nil, points: [MetricSeriesPoint]) {
        self.name = name
        self.category = category
        self.version = version
        self.points = points
    }
}

struct MetricSeriesPoint: Decodable {
    let date: Int64
    let value: MetricValue
}

enum MetricValue: Decodable, Equatable {
    case int(Int)
    case double(Double)

    private enum CodingKeys: String, CodingKey {
        case int, double
    }

    init(from decoder: any Decoder) throws {
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
    var doubleValue: Double {
        switch self {
        case .int(let value):
            Double(value)
        case .double(let value):
            value
        }
    }

    var intValue: Int {
        switch self {
        case .int(let value):
            value
        case .double(let value):
            Int(value.rounded())
        }
    }
}
