//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//
import Foundation
import Scout

struct BacktraceRecord: RecordDecodable {
    static let recordType = "Backtrace"
    static let desiredKeys = ["incident_id", "backtrace", "date"]

    let id: String
    let incidentID: String
    let payload: Data

    init(record: Record) throws {
        guard let incidentID: String = record["incident_id"], let payload: Data = record["backtrace"] else {
            throw IncompleteBacktraceError(recordID: record.recordID)
        }
        self.id = record.recordID
        self.incidentID = incidentID
        self.payload = payload
    }

    var record: Record {
        var record = Record(recordType: Self.recordType, recordID: id)
        record["incident_id"] = incidentID
        record["backtrace"] = payload
        return record
    }
}

struct IncompleteBacktraceError: Error {
    let recordID: String
}
