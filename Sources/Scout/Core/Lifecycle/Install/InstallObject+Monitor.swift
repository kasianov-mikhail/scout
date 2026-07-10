//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension InstallObject: PartialMonitor {
    static func trigger(in context: NSManagedObjectContext) throws {
        let request = NSFetchRequest<InstallObject>(entityName: "InstallObject")
        request.predicate = NSPredicate(format: "installID == %@", IDs.install as CVarArg)
        request.fetchLimit = 1

        guard try context.fetch(request).isEmpty else {
            return
        }

        let install = context.insert(InstallObject.self)
        install.date = Date()
        install.device = try context.existing(DeviceObject.self, key: "deviceID", id: IDs.device)
        try context.save()
    }
}
