//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension DateObject {
    static func cleanup(backends: [Backend], in context: NSManagedObjectContext) throws {
        let cutoff = Date().addingDay(-7)
        let backendIDs = Set(backends.map(\.id))

        let request = NSFetchRequest<DateObject>(entityName: "DateObject")
        request.predicate = NSPredicate(format: "datePrimitive < %@", cutoff as NSDate)

        for object in try context.fetch(request) where object.references.count == 0 {
            if let syncable = object as? SyncableObject, syncable.hasPendingDelivery(to: backendIDs) {
                continue
            }
            context.delete(object)
        }

        try context.save()
    }
}
