//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(InstallEntry)
package final class InstallEntry: SyncableEntry, HasDevice {
    package static let recordType = Install.recordType

    @NSManaged var installID: UUID
    @NSManaged var osVersion: String?
    @NSManaged var device: DeviceEntry?
    @NSManaged var launches: Set<LaunchEntry>
    @NSManaged var firstSeen: Set<FirstSeenEntry>
    @NSManaged var retentionMarks: Set<RetentionMarkEntry>

    override var references: Set<DateEntry> {
        Set(Array(launches) + Array(firstSeen))
    }

    override var isPurgeable: Bool {
        false
    }
}

extension InstallEntry: RecordEncodable {
    package var record: Record {
        var record = Record(recordType: Self.recordType, recordID: installID.uuidString)

        record["date"] = date
        record["install_id"] = installID.uuidString
        record["device_id"] = deviceID?.uuidString
        record.setValues(metadata)

        return record
    }
}
