//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension InstallEntry {
    package struct Trigger: Command {
        let installID: UUID
        let deviceID: UUID

        func execute(in context: NSManagedObjectContext) throws {
            let existing = try context.existing(InstallEntry.self, key: "installID", id: installID)
            let install = existing ?? context.insert(InstallEntry.self)

            if existing == nil {
                install.installID = installID
                install.date = Date()
            }

            if install.device == nil {
                install.device = try context.existing(DeviceEntry.self, key: "deviceID", id: deviceID)
            }

            if context.hasChanges {
                try context.save()
            }
        }
    }
}
