//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(DeviceObject)
final class DeviceObject: SyncableObject {
    static let recordType = "Device"

    @NSManaged var deviceID: UUID
    @NSManaged var model: String?
    @NSManaged var installs: Set<InstallObject>

    override var references: Set<DateObject> {
        Set(Array(installs))
    }
}

extension DeviceObject: RecordEncodable {
    var record: Record {
        var record = Record(recordType: Self.recordType, recordID: deviceID.uuidString)

        record["date"] = date
        record["device_id"] = deviceID.uuidString
        record["model"] = model

        record.setValues(metadata)

        return record
    }
}
