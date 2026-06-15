//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(CrashObject)
final class CrashObject: TrackedObject, Syncable, GridBatch {
    static let recordType = "Crash"
    @NSManaged var name: String?
    @NSManaged var crashID: UUID
    @NSManaged var reason: String?
    @NSManaged var stackTrace: Data?
}

extension CrashObject: RecordRepresentable {
    var toRecord: Record {
        var record = Record(recordType: Self.recordType, id: RecordID(recordName: crashID.uuidString))

        record["name"] = name
        record["reason"] = reason
        record["stack_trace"] = stackTrace
        record["date"] = date
        record["uuid"] = crashID.uuidString

        record.setValues(metadata)

        return record
    }
}
