//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension SyncableEntry {
    static func cleanup(backends: [Backend], in context: NSManagedObjectContext) throws {
        let cutoff = Date().addingDay(-7)

        let request = NSFetchRequest<SyncableEntry>(entityName: "SyncableEntry")
        request.predicate = NSPredicate(
            format: "SUBQUERY(deliveries, $d, $d.backendID IN %@ AND $d.isPending == YES AND $d.attempts < %d).@count == 0 AND datePrimitive < %@",
            backends.map(\.id),
            DeliveryEntry.maxAttempts,
            cutoff as NSDate
        )

        for object in try context.fetch(request) where object.references.count == 0 {
            context.delete(object)
        }

        try context.save()
    }
}
