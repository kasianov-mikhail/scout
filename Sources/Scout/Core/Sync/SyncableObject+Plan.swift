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
        var progress: SyncDelivery.Progress = []

        if type(of: object).prefersRawDelivery ?? (aggregator == nil) {
            progress.insert(.raw)
        }
        if aggregator != nil {
            progress.insert(.matrix)
        }

        if !progress.isEmpty {
            let entity = NSEntityDescription.entity(forEntityName: "SyncDelivery", in: context)!
            let row = SyncDelivery(entity: entity, insertInto: context)
            row.backendID = id
            row.object = object
            row.progress = progress
        }
    }
}
