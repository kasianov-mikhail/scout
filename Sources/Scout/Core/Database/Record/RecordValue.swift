//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// A typed record field value, the backend-neutral currency the rest of the
/// package speaks instead of a `CKRecord` value.
///
/// It is also the wire format shared with Scout servers: encoded as a
/// single-key JSON object, e.g. `{"string": "login"}`. Dates travel as integer
/// milliseconds since the Unix epoch so equality survives the round trip;
/// bytes travel as base64.
///
enum RecordValue: Equatable, Sendable {
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

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let value = try container.decodeIfPresent(String.self, forKey: .string) {
            self = .string(value)
        } else if let value = try container.decodeIfPresent(Int64.self, forKey: .int) {
            self = .int(value)
        } else if let value = try container.decodeIfPresent(Double.self, forKey: .double) {
            self = .double(value)
        } else if let value = try container.decodeIfPresent(Int64.self, forKey: .date) {
            self = .date(Date(timeIntervalSince1970: Double(value) / 1000))
        } else if let value = try container.decodeIfPresent(Data.self, forKey: .bytes) {
            self = .bytes(value)
        } else if let value = try container.decodeIfPresent([String].self, forKey: .strings) {
            self = .strings(value)
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unknown field value type"
                )
            )
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .string(let value):
            try container.encode(value, forKey: .string)
        case .int(let value):
            try container.encode(value, forKey: .int)
        case .double(let value):
            try container.encode(value, forKey: .double)
        case .date(let value):
            try container.encode(Int64((value.timeIntervalSince1970 * 1000).rounded()), forKey: .date)
        case .bytes(let value):
            try container.encode(value, forKey: .bytes)
        case .strings(let value):
            try container.encode(value, forKey: .strings)
        }
    }
}

// MARK: - Foundation Bridging

extension RecordValue {
    /// Wraps a loosely-typed value — as produced by an object's `metadata`
    /// dictionary — in its matching case, mirroring how a `CKRecord` stores it.
    ///
    /// Numbers are split by their Core Foundation storage: floating-point
    /// numbers become `double`, everything else `int`.
    ///
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
        case let value as NSNumber:
            if CFNumberIsFloatType(value) {
                self = .double(value.doubleValue)
            } else {
                self = .int(value.int64Value)
            }
        default:
            return nil
        }
    }
}

// MARK: - Typed Access

/// A scalar a record field converts to and from, powering its typed subscript.
///
protocol RecordValueConvertible {
    init?(recordValue: RecordValue)
    var recordValue: RecordValue { get }
}

extension String: RecordValueConvertible {
    init?(recordValue: RecordValue) {
        guard case .string(let value) = recordValue else { return nil }
        self = value
    }

    var recordValue: RecordValue { .string(self) }
}

extension Int: RecordValueConvertible {
    init?(recordValue: RecordValue) {
        guard case .int(let value) = recordValue else { return nil }
        self = Int(value)
    }

    var recordValue: RecordValue { .int(Int64(self)) }
}

extension Int64: RecordValueConvertible {
    init?(recordValue: RecordValue) {
        guard case .int(let value) = recordValue else { return nil }
        self = value
    }

    var recordValue: RecordValue { .int(self) }
}

extension Double: RecordValueConvertible {
    init?(recordValue: RecordValue) {
        guard case .double(let value) = recordValue else { return nil }
        self = value
    }

    var recordValue: RecordValue { .double(self) }
}

extension Date: RecordValueConvertible {
    init?(recordValue: RecordValue) {
        guard case .date(let value) = recordValue else { return nil }
        self = value
    }

    var recordValue: RecordValue { .date(self) }
}

extension Data: RecordValueConvertible {
    init?(recordValue: RecordValue) {
        guard case .bytes(let value) = recordValue else { return nil }
        self = value
    }

    var recordValue: RecordValue { .bytes(self) }
}

extension Array: RecordValueConvertible where Element == String {
    init?(recordValue: RecordValue) {
        guard case .strings(let value) = recordValue else { return nil }
        self = value
    }

    var recordValue: RecordValue { .strings(self) }
}
