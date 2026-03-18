//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData

@objc(SessionObject)
final class SessionObject: SyncableObject, Syncable {
    static func group(in context: NSManagedObjectContext) throws -> [SessionObject]? {
        try batch(in: context, matching: [\.week])
    }
}

extension SessionObject: CKRepresentable {
    var toRecord: CKRecord {
        let record = CKRecord(recordType: "Session")

        record["start_date"] = date
        record["end_date"] = endDate
        record["session_id"] = sessionID?.uuidString

        record.setValuesForKeys(metadata)

        return record
    }
}
