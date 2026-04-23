//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension SessionObject: Monitor {
    static func trigger(in context: NSManagedObjectContext) throws {
        IDs.session = UUID()

        let entity = NSEntityDescription.entity(forEntityName: "SessionObject", in: context)!
        let session = SessionObject(entity: entity, insertInto: context)
        session.date = Date()
        try context.save()
    }

    /// Marks the latest session for the current launch as ended.
    ///
    /// Idempotent — returns without changes when the session is already
    /// closed. Background-entry notifications can fire repeatedly
    /// (scene lifecycle, state restoration), and a no-op on the second
    /// call preserves the first observed end time.
    ///
    static func complete(in context: NSManagedObjectContext) throws {
        let request = NSFetchRequest<SessionObject>(entityName: "SessionObject")
        request.sortDescriptors = [NSSortDescriptor(key: "datePrimitive", ascending: false)]
        request.predicate = NSPredicate(format: "launchID == %@", IDs.launch as CVarArg)
        request.fetchLimit = 1

        guard let session = try context.fetch(request).first else {
            throw MonitorError.notFound
        }

        if session.endDate == nil {
            session.endDate = Date()
            try context.save()
        }
    }
}
