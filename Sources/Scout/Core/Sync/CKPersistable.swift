//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

typealias CKPersistable = CKInitializable & CKRepresentable

protocol CKInitializable {
    init(record: CKRecord) throws
}

protocol CKRepresentable {
    var toRecord: CKRecord { get }
}

extension EventObject: CKRepresentable {
    var toRecord: CKRecord {
        let record = CKRecord(recordType: "Event")

        record["name"] = name
        record["level"] = level
        record["params"] = params
        record["param_count"] = paramCount

        record["date"] = date
        record.setValuesForKeys(dateFields)

        record["uuid"] = eventID?.uuidString
        record["session_id"] = sessionID?.uuidString
        record["launch_id"] = launchID?.uuidString
        record["user_id"] = userID?.uuidString

        record["version"] = 1

        return record
    }
}

extension SessionObject: CKRepresentable {
    var toRecord: CKRecord {
        let record = CKRecord(recordType: "Session")

        record["start_date"] = date
        record["end_date"] = endDate
        record.setValuesForKeys(dateFields)

        record["session_id"] = sessionID?.uuidString
        record["launch_id"] = launchID?.uuidString
        record["user_id"] = userID?.uuidString

        record["version"] = 1

        return record
    }
}
