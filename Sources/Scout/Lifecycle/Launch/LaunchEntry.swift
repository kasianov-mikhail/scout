//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(LaunchEntry)
package final class LaunchEntry: SyncableEntry, HasInstall {
    package static let recordType = Launch.recordType

    @NSManaged var endDate: Date?
    @NSManaged var launchID: UUID
    @NSManaged var processID: Int32
    @NSManaged var install: InstallEntry?
    @NSManaged var scopedEntries: Set<LaunchScopeEntry>
    @NSManaged var sessionScopedEntries: Set<SessionScopeEntry>

    override var references: Set<DateEntry> {
        (scopedEntries as Set<DateEntry>).union(sessionScopedEntries as Set<DateEntry>)
    }

    override var isPurgeable: Bool {
        endDate != nil
    }
}

extension LaunchEntry: RecordEncodable {
    package var record: Record {
        var record = Record(recordType: Self.recordType, recordID: launchID.uuidString)

        record["start_date"] = date
        record["end_date"] = endDate
        record["launch_id"] = launchID.uuidString
        record["install_id"] = installID?.uuidString
        record["device_id"] = deviceID?.uuidString

        record.setValues(metadata)

        return record
    }
}
