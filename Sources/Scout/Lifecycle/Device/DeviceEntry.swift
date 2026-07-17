//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(DeviceEntry)
package final class DeviceEntry: SyncableEntry {
    package static let recordType = "Device"

    @NSManaged var deviceID: UUID
    @NSManaged var model: String?
    @NSManaged var installs: Set<InstallEntry>

    override var references: Set<DateEntry> {
        Set(Array(installs))
    }
}

extension DeviceEntry: RecordEncodable {
    package var record: Record {
        var record = Record(recordType: Self.recordType, recordID: deviceID.uuidString)

        record["date"] = date
        record["device_id"] = deviceID.uuidString
        record["model"] = model

        record.setValues(metadata)

        return record
    }
}
