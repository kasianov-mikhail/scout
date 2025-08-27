//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension EventObject: Syncable {
    static func group(in context: NSManagedObjectContext) throws -> SyncGroup<Cell<Int>>? {
        let seedReq = NSFetchRequest<EventObject>(entityName: "EventObject")
        seedReq.predicate = NSPredicate(format: "isSynced == false")
        seedReq.fetchLimit = 1

        guard let seed = try context.fetch(seedReq).first else {
            return nil
        }
        guard let name = seed.name else {
            throw SyncableError.missingProperty(#keyPath(EventObject.name))
        }
        guard let week = seed.week else {
            throw SyncableError.missingProperty(#keyPath(EventObject.week))
        }

        let batchReq = NSFetchRequest<EventObject>(entityName: "EventObject")
        batchReq.predicate = NSPredicate(
            format: "isSynced == false AND name == %@ AND week == %@",
            name,
            week as NSDate
        )

        let batch = try context.fetch(batchReq)

        return SyncGroup(
            recordType: "DateIntMatrix",
            name: name,
            date: week,
            representables: batch,
            batch: batch,
            fields: batch.grouped(by: \.hour).mapValues(\.count)
        )
    }
}
