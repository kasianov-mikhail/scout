//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(LaunchEntry)
final class LaunchEntry: SyncableEntry, HasInstall {
    static let recordType = "Launch"

    @NSManaged var endDate: Date?
    @NSManaged var launchID: UUID
    @NSManaged var install: InstallEntry?
    @NSManaged var sessions: Set<SessionEntry>
    @NSManaged var versions: Set<VersionEntry>
    @NSManaged var visits: Set<VisitEntry>

    override var references: Set<DateEntry> {
        Set(Array(sessions) + Array(versions) + Array(visits))
    }
}

extension LaunchEntry: RecordEncodable {
    var record: Record {
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
