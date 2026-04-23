//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData

@objc(EventObject)
final class EventObject: NamedObject, Syncable {
    static let recordType = "Event"
    @NSManaged var eventID: UUID
    @NSManaged var level: String?
    @NSManaged var paramCount: Int64
    @NSManaged var params: Data?

    static func group(in context: NSManagedObjectContext) throws -> [EventObject]? {
        try batch(in: context, matching: [\.name, \.week])
    }

    static func matrix(of batch: [EventObject]) throws -> GridMatrix<Int> {
        try NamedObject.matrix(of: batch)
    }
}

extension EventObject: CKRepresentable {
    var toRecord: CKRecord {
        let recordID = CKRecord.ID(recordName: eventID.uuidString)
        let record = CKRecord(recordType: Self.recordType, recordID: recordID)

        record["name"] = name
        record["level"] = level
        record["params"] = params
        record["param_count"] = paramCount
        record["date"] = date
        record["uuid"] = eventID.uuidString
        record["session_id"] = sessionID.uuidString

        record.setValuesForKeys(metadata)

        return record
    }
}
