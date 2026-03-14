//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

extension CrashObject: CKRepresentable {
    var toRecord: CKRecord {
        let record = CKRecord(recordType: "Crash")

        record["name"] = name
        record["reason"] = reason
        record["stack_trace"] = stackTrace

        record["date"] = date
        record.setValuesForKeys(dateFields)

        record["uuid"] = crashID?.uuidString
        record["launch_id"] = launchID?.uuidString
        record["user_id"] = userID?.uuidString

        record["version"] = 1

        return record
    }
}
