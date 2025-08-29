//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(EventObject)
final class EventObject: TrackedObject, Syncable {
    static func group(in context: NSManagedObjectContext) throws -> SyncGroup<EventObject>? {
        let seedReq = CoreDataSyncGroupBuilder.createSeedRequest(for: EventObject.self)

        guard let seed = try context.fetch(seedReq).first else {
            return nil
        }
        guard let name = seed.name else {
            throw SyncableError.missingProperty("name")
        }
        guard let week = seed.week else {
            throw SyncableError.missingProperty("week")
        }

        let additionalPredicate = NSPredicate(
            format: "name == %@ AND week == %@",
            name,
            week as NSDate
        )
        let batchReq = CoreDataSyncGroupBuilder.createBatchRequest(for: EventObject.self, additionalPredicate: additionalPredicate)

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
