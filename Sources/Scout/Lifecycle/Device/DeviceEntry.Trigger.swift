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
            try context.upsert(DeviceEntry.self, key: "deviceID", id: deviceID) { device in
                if device.model == nil {
                    device.model = SystemInfo.deviceModel
                }
            }
        }
    }
}
