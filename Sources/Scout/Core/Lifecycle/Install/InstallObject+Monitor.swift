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
        request.fetchLimit = 1

        guard try context.fetch(request).isEmpty else {
            return
        }

        let entity = NSEntityDescription.entity(forEntityName: "InstallObject", in: context)!
        let install = InstallObject(entity: entity, insertInto: context)
        install.date = Date()
        try context.save()
    }
}
