//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(InstallObject)
final class InstallObject: SyncableObject, HasDevice {
    static let recordType = "Install"

    @NSManaged var installID: UUID
    @NSManaged var device: DeviceObject?
    @NSManaged var launches: Set<LaunchObject>
    @NSManaged var markers: Set<VersionMarker>

    override var references: Set<DateObject> {
        Set(Array(launches) + Array(markers))
    }
}

extension InstallObject: RecordEncodable {
    var record: Record {
        var record = Record(recordType: Self.recordType, recordID: installID.uuidString)

        record["date"] = date
        record["install_id"] = installID.uuidString
        record["device_id"] = deviceID?.uuidString
        record.setValues(metadata)

        return record
    }
}
