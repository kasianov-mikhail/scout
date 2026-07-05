//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension SyncableObject {
    static func plan(backends: [Backend], in context: NSManagedObjectContext) throws {
        let request = NSFetchRequest<SyncableObject>(entityName: "SyncableObject")
        // deliveries.@count == 0: a newly added backend only receives objects
        // created after it was added; existing history is intentionally not backfilled.
        request.predicate = NSPredicate(format: "deliveries.@count == 0")

        for object in try context.fetch(request) {
            for backend in backends {
                backend.planDelivery(for: object, in: context)
            }
        }

        try context.save()
    }
}

extension Backend {
    fileprivate func planDelivery(for object: SyncableObject, in context: NSManagedObjectContext) {
        guard !type(of: object).isLocalOnly else { return }

        let row = context.insert(SyncDelivery.self)
        row.backendID = id
        row.object = object
        row.progress = .raw
    }
}
