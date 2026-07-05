//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension DeviceObject: PartialMonitor {
    static func trigger(in context: NSManagedObjectContext) throws {
        let request = NSFetchRequest<DeviceObject>(entityName: "DeviceObject")
        request.predicate = NSPredicate(format: "deviceID == %@", IDs.device as CVarArg)
        request.fetchLimit = 1

        guard try context.fetch(request).isEmpty else {
            return
        }

        let device = context.insert(DeviceObject.self)
        device.date = Date()
        try context.save()
    }
}
