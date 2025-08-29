//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(SessionObject)
final class SessionObject: IDObject, Syncable {
    static func group(in context: NSManagedObjectContext) throws -> SyncGroup<SessionObject>? {
        let seedReq = CoreDataSyncGroupBuilder.createSeedRequest(for: SessionObject.self)

        guard let seed = try context.fetch(seedReq).first else {
            return nil
        }
        guard let week = seed.week else {
            throw SyncableError.missingProperty(#keyPath(SessionObject.week))
        }

        let additionalPredicate = NSPredicate(format: "week == %@", week as NSDate)
        let batchReq = CoreDataSyncGroupBuilder.createBatchRequest(for: SessionObject.self, additionalPredicate: additionalPredicate)

        let batch = try context.fetch(batchReq)

        return SyncGroup(
            recordType: "DateIntMatrix",
            name: "Session",
            date: week,
            representables: batch,
            batch: batch
        )
    }

    static func parse(of batch: [SessionObject]) -> [Cell<Int>] {
        batch.grouped(by: \.date).mapValues(\.count).map(Cell.init)
    }
}
