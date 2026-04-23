//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData

@objc(CrashObject)
final class CrashObject: NamedObject, Syncable {
    static let recordType = "Crash"
    @NSManaged var crashID: UUID?
    @NSManaged var reason: String?
    @NSManaged var stackTrace: Data?

    static func group(in context: NSManagedObjectContext) throws -> [CrashObject]? {
        try batch(in: context, matching: [\.name, \.week])
    }

    static func matrix(of batch: [CrashObject]) throws -> GridMatrix<Int> {
        try NamedObject.matrix(of: batch)
    }
}

extension CrashObject: CKRepresentable {
    var toRecord: CKRecord {
        let recordID = CKRecord.ID(recordName: crashID!.uuidString)
        let record = CKRecord(recordType: Self.recordType, recordID: recordID)

        record["name"] = name
        record["reason"] = reason
        record["stack_trace"] = stackTrace
        record["date"] = date
        record["uuid"] = crashID?.uuidString

        record.setValuesForKeys(metadata)

        return record
    }
}
