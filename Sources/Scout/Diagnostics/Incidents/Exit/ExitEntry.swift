//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(ExitEntry)
package final class ExitEntry: SyncableEntry {
    package static let recordType = "Exit"

    @NSManaged var exitID: UUID
    @NSManaged var appVersion: String?
    @NSManaged var reason: String
    @NSManaged var count: Int
    @NSManaged var windowStart: Date?
}

extension ExitEntry: RecordEncodable {
    package var record: Record {
        var record = Record(recordType: Self.recordType, recordID: exitID.uuidString)

        record["category"] = reason
        record["value"] = count
        record["app_version"] = appVersion
        record["date"] = date
        record["date_start"] = windowStart
        record["uuid"] = exitID.uuidString

        record.setValues(metadata)

        return record
    }
}
