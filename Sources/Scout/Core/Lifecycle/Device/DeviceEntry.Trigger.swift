//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension DeviceEntry {
    struct Trigger: Command {
        let deviceID: UUID

        func execute(in context: NSManagedObjectContext) throws {
            let request = NSFetchRequest<DeviceEntry>(entityName: "DeviceEntry")
            request.predicate = NSPredicate(format: "deviceID == %@", deviceID as CVarArg)
            request.fetchLimit = 1

            guard try context.fetch(request).isEmpty else {
                return
            }

            let device = context.insert(DeviceEntry.self)
            device.deviceID = deviceID
            device.date = Date()
            device.model = SystemInfo.deviceModel
            try context.save()
        }
    }
}
