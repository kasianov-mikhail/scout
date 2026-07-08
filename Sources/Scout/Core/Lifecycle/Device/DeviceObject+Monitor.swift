//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension DeviceObject: PartialMonitor {
    static func trigger(in context: NSManagedObjectContext) throws {
        let hub = context.persistentStoreCoordinator?.hubObjectIDs

        let request = NSFetchRequest<DeviceObject>(entityName: "DeviceObject")
        request.predicate = NSPredicate(format: "deviceID == %@", IDs.device as CVarArg)
        request.fetchLimit = 1

        if let existing = try context.fetch(request).first {
            hub?.device = existing.objectID
            return
        }

        let device = context.insert(DeviceObject.self)
        device.date = Date()
        device.deviceID = IDs.device
        device.model = SystemInfo.deviceModel
        try context.save()
        hub?.device = device.objectID
    }
}
