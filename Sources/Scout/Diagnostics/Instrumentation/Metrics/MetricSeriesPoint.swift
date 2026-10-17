//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package struct MetricSeriesPoint: Decodable, Sendable {
    package let date: Date
    package let value: Double

    package init(date: Date, value: Double) {
        self.date = date
        self.value = value
    }

    private enum CodingKeys: String, CodingKey {
        case date, value
    }

    private enum ValueKeys: String, CodingKey {
        case int, double
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let value = try container.nestedContainer(keyedBy: ValueKeys.self, forKey: .value)

        self.date = Date(millisecondsSince1970: try container.decode(Int64.self, forKey: .date))

        if let integer = try value.decodeIfPresent(Int.self, forKey: .int) {
            self.value = Double(integer)
        } else if let double = try value.decodeIfPresent(Double.self, forKey: .double) {
            self.value = double
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
