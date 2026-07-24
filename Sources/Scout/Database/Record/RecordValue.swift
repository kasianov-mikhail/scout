//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package enum RecordValue: Equatable, Sendable {
    case string(String)
    case int(Int64)
    case double(Double)
    case date(Date)
    case bytes(Data)
    case strings([String])
}

extension RecordValue: Codable {
    private enum CodingKeys: String, CodingKey {
        case string, int, double, date, bytes, strings
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let value = try container.decodeIfPresent(String.self, forKey: .string) {
            self = .string(value)
        } else if let value = try container.decodeIfPresent(Int64.self, forKey: .int) {
            self = .int(value)
        } else if let value = try container.decodeIfPresent(Double.self, forKey: .double) {
            self = .double(value)
        } else if let value = try container.decodeIfPresent(Int64.self, forKey: .date) {
            self = .date(Date(millisecondsSince1970: value))
        } else if let value = try container.decodeIfPresent(Data.self, forKey: .bytes) {
            self = .bytes(value)
        } else if let value = try container.decodeIfPresent([String].self, forKey: .strings) {
            self = .strings(value)
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unknown field value type"))
        }
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .string(let value):
            try container.encode(value, forKey: .string)
        case .int(let value):
            try container.encode(value, forKey: .int)
        case .double(let value):
            try container.encode(value, forKey: .double)
        case .date(let value):
            try container.encode(value.millisecondsSince1970, forKey: .date)
        case .bytes(let value):
            try container.encode(value, forKey: .bytes)
        case .strings(let value):
            try container.encode(value, forKey: .strings)
        }
    }
}

extension RecordValue {
    init?(any value: Any) {
        switch value {
        case let value as String:
            self = .string(value)
        case let value as Date:
            self = .date(value)
        case let value as Data:
            self = .bytes(value)
        case let value as [String]:
            self = .strings(value)
        case let value as NSNumber where CFNumberIsFloatType(value):
            self = .double(value.doubleValue)
        case let value as NSNumber:
            self = .int(value.int64Value)
        default:
            return nil
        }
    }
}

extension RecordValue {
    package var value: Double? {
        switch self {
        case .int(let value):
            Double(value)
        case .double(let value):
            value
        case .date(let value):
            value.timeIntervalSince1970
        default:
            nil
        }
    }
}
