//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension SessionObject {
    struct Complete: Command {
        let launchID: UUID

        func execute(in context: NSManagedObjectContext) throws {
            let request = NSFetchRequest<SessionObject>(entityName: "SessionObject")
            request.sortDescriptors = [NSSortDescriptor(key: DateObject.datePrimitiveKey, ascending: false)]
            request.predicate = NSPredicate(format: "launch.launchID == %@", launchID as CVarArg)
            request.fetchLimit = 1

            guard let session = try context.fetch(request).first else {
                throw LifecycleError.notFound
            }

            if session.endDate == nil {
                session.endDate = Date()
                try context.save()
            }
        }
    }
}
