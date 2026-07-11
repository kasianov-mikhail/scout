//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension InstallEntry {
    struct Trigger: Command {
        let installID: UUID
        let deviceID: UUID

        func execute(in context: NSManagedObjectContext) throws {
            let request = NSFetchRequest<InstallEntry>(entityName: "InstallEntry")
            request.predicate = NSPredicate(format: "installID == %@", installID as CVarArg)
            request.fetchLimit = 1

            guard try context.fetch(request).isEmpty else {
                return
            }

            let install = context.insert(InstallEntry.self)
            install.installID = installID
            install.date = Date()
            install.device = try context.existing(DeviceEntry.self, key: "deviceID", id: deviceID)
            try context.save()
        }
    }
}
