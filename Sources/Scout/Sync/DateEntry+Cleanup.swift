//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension DateEntry {
    static func cleanup(backends: [Backend], in context: NSManagedObjectContext) throws {
        let cutoff = Date().addingDay(-7)
        let backendIDs = Set(backends.map(\.id))
        let retained = try DeliveryEntry.retainedIDs(to: backendIDs, in: context)

        let request = NSFetchRequest<DateEntry>(entityName: "DateEntry")
        request.predicate = NSPredicate(format: "datePrimitive < %@", cutoff as NSDate)

        for object in try context.fetch(request)
        where object.isPurgeable && object.references.count == 0 && !retained.contains(object.objectID) {
            context.delete(object)
        }

        try context.save()
    }
}
