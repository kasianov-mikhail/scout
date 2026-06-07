//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData

@objc(CrashObject)
final class CrashObject: TrackedObject, Syncable, GridBatch {
    static let recordType = "Crash"
    @NSManaged var name: String?
    @NSManaged var crashID: UUID
    @NSManaged var reason: String?
    @NSManaged var stackTrace: Data?
}

extension CrashObject: CKRepresentable {
    var toRecord: CKRecord {
        let recordID = CKRecord.ID(recordName: crashID.uuidString)
        let record = CKRecord(recordType: Self.recordType, recordID: recordID)

        record["name"] = name
        record["reason"] = reason
        record["stack_trace"] = stackTrace
        record["date"] = date
        record["uuid"] = crashID.uuidString

        record.setValuesForKeys(metadata)

        return record
    }
}
