//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension DeviceEntry {
    package struct Trigger: Command {
        let deviceID: UUID

        func execute(in context: NSManagedObjectContext) throws {
            let existing = try context.existing(DeviceEntry.self, key: "deviceID", id: deviceID)
            let device = existing ?? context.insert(DeviceEntry.self)

            if existing == nil {
                device.deviceID = deviceID
                device.date = Date()
            }

            if device.model == nil {
                device.model = SystemInfo.deviceModel
            }

            if device.hasChanges {
                device.requeue()
            }

            if context.hasChanges {
                try context.save()
            }
        }
    }
}
