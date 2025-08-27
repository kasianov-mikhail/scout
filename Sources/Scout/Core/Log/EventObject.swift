//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

final class EventObject: TrackedObject, Syncable {
    static func group(in context: NSManagedObjectContext) throws -> SyncGroup<EventObject>? {
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
            batch: batch
        )
    }

    static func parse(of batch: [EventObject]) -> [Cell<Int>] {
        batch.grouped(by: \.hour).mapValues(\.count).map(Cell.init)
    }
}
