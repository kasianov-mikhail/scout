//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension InstallObject: PartialMonitor {
    static func trigger(in context: NSManagedObjectContext) throws {
        let hub = context.persistentStoreCoordinator?.hubObjectIDs

        let request = NSFetchRequest<InstallObject>(entityName: "InstallObject")
        request.predicate = NSPredicate(format: "installID == %@", IDs.install as CVarArg)
        request.fetchLimit = 1

        if let existing = try context.fetch(request).first {
            hub?.install = existing.objectID
            return
        }

        let install = context.insert(InstallObject.self)
        install.date = Date()
        install.installID = IDs.install
        try context.save()
        hub?.install = install.objectID
    }
}
