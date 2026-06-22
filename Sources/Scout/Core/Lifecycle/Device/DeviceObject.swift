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

    func installs(in context: NSManagedObjectContext) throws -> [InstallObject] {
        let request = NSFetchRequest<InstallObject>(entityName: "InstallObject")
        request.predicate = NSPredicate(format: "deviceID == %@", deviceID as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "datePrimitive", ascending: true)]
        return try context.fetch(request)
    }
}

extension DeviceObject: RecordEncodable {
    var record: Record {
        var record = Record(recordType: Self.recordType, recordID: deviceID.uuidString)

        record["date"] = date
        record["device_id"] = deviceID.uuidString

        record.setValues(metadata)

        return record
    }
}
