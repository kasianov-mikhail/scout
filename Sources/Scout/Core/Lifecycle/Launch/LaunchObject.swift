//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(LaunchObject)
final class LaunchObject: SyncableObject, HasInstall {
    static let recordType = "Launch"

    @NSManaged var endDate: Date?
    @NSManaged var launchID: UUID
    @NSManaged var install: InstallObject?
    @NSManaged var sessions: Set<SessionObject>
    @NSManaged var versions: Set<VersionObject>

    override var references: Set<DateObject> {
        Set(Array(sessions) + Array(versions))
    }

    override func awakeFromInsert() {
        super.awakeFromInsert()
        launchID = IDs.launch
    }
}

extension LaunchObject: RecordEncodable {
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
