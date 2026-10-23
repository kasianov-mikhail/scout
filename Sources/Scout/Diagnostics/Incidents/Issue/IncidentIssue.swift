//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct IncidentIssue: Equatable {
    let fingerprint: String
    let kind: Kind
    let status: Status
    let resolvedVersion: String?
    let date: Date
    let id: String
}

extension IncidentIssue {
    enum Kind: String {
        case crash
        case hang
        case resource
    }

    enum Status: String {
        case open
        case resolved
        case ignored
    }
}

extension IncidentIssue: RecordDecodable {
    static let recordType = "Issue"

    static let desiredKeys = [
        "fingerprint",
        "category",
        "status",
        "resolved_version",
        "date",
    ]

    init(record: Record) throws {
        guard let fingerprint: String = record["fingerprint"] else {
            throw MissingFieldError(field: "fingerprint")
        }
        guard let kind = record["category"].flatMap(Kind.init(rawValue:)) else {
            throw MissingFieldError(field: "category")
        }
        guard let status = record["status"].flatMap(Status.init(rawValue:)) else {
            throw MissingFieldError(field: "status")
        }
        guard let date: Date = record["date"] else {
            throw MissingFieldError(field: "date")
        }

        self.init(
            fingerprint: fingerprint,
            kind: kind,
            status: status,
            resolvedVersion: record["resolved_version"],
            date: date,
            id: record.recordID
        )
    }
}

extension IncidentIssue: RecordEncodable {
    var record: Record {
        var record = Record(recordType: Self.recordType, recordID: id)
        record["fingerprint"] = fingerprint
        record["category"] = kind.rawValue
        record["status"] = status.rawValue
        record["resolved_version"] = resolvedVersion
        record["date"] = date
        return record
    }
}

private struct MissingFieldError: LocalizedError {
    let field: String

    var errorDescription: String? {
        "The Issue record has no valid \(field)"
    }
}
