//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// A backend that answers flat per-name metric series natively.
///
/// CloudKit cannot aggregate, so the client reads the `DateIntMatrix` /
/// `DateDoubleMatrix` grids and flattens them. A Scout server aggregates over
/// raw records and serves a finished series, so the client fetches a whole
/// telemetry category in one request instead.
///
protocol MetricSeriesReading {
    /// The series for every name in `category` of the given value flavor
    /// (`"int"` or `"double"`) over `range`.
    ///
    func metricSeries(category: String, values: String, in range: Range<Date>) async throws -> [MetricSeries]
}

/// The server's grouped metric series — the response of
/// `GET /api/v1/metrics/series`.
///
struct MetricSeriesResponse: Decodable {
    let series: [MetricSeries]
}

/// One name's series over the requested range.
///
struct MetricSeries: Decodable {
    let name: String
    let category: String?
    let points: [MetricSeriesPoint]
}

/// One bucket of a series: the aggregate `value` at `date`, milliseconds since
/// the Unix epoch at the UTC bucket start.
///
struct MetricSeriesPoint: Decodable {
    let date: Int64
    let value: MetricValue
}

/// A typed series value.
///
/// `int` carries record counts and `IntMetric` sums, `double` carries
/// `DoubleMetric` sums. Encoded as a single-key object, e.g. `{"int": 42}`,
/// matching the rest of the wire format.
///
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
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unknown metric value type"
                )
            )
        }
    }
}
