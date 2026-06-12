//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

/// A typed record field value, the wire format shared with Scout servers.
///
/// Encoded as a single-key JSON object, e.g. `{"string": "login"}`. Dates
/// travel as integer milliseconds since the Unix epoch so equality survives
/// the round trip; bytes travel as base64.
///
enum HTTPFieldValue: Equatable, Sendable {
    case string(String)
    case int(Int64)
    case double(Double)
    case date(Date)
    case bytes(Data)
    case strings([String])
}

extension HTTPFieldValue: Codable {
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

// MARK: - CloudKit Bridging

extension HTTPFieldValue {
    /// Maps a `CKRecord` value to its wire form.
    ///
    /// Numbers are split by their Core Foundation storage: floating-point
    /// numbers become `double`, everything else `int`.
    ///
    init?(recordValue: Any) {
        switch recordValue {
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

    var recordValue: any CKRecordValueProtocol {
        switch self {
        case .string(let value): value
        case .int(let value): value
        case .double(let value): value
        case .date(let value): value
        case .bytes(let value): value
        case .strings(let value): value
        }
    }
}

// MARK: - Records

/// Wire representation of a single record.
struct HTTPRecord: Codable, Equatable, Sendable {
    let recordType: String
    let recordName: String
    var fields: [String: HTTPFieldValue]
}

extension HTTPRecord {
    init(record: CKRecord) {
        recordType = record.recordType
        recordName = record.recordID.recordName
        fields = Dictionary(
            uniqueKeysWithValues: record.allKeys().compactMap { key in
                record[key].flatMap(HTTPFieldValue.init).map { (key, $0) }
            }
        )
    }

    var toRecord: CKRecord {
        let record = CKRecord(
            recordType: recordType,
            recordID: CKRecord.ID(recordName: recordName)
        )
        for (key, value) in fields {
            record[key] = value.recordValue
        }
        return record
    }
}
