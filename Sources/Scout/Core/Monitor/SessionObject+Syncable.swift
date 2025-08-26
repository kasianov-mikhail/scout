//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension SessionObject: Syncable {
    static func group(in context: NSManagedObjectContext) throws -> SyncGroup<Int>? {
        let seedReq = SessionObject.fetchRequest()
        seedReq.predicate = NSPredicate(format: "isSynced == false")
        seedReq.fetchLimit = 1

        guard let seed = try context.fetch(seedReq).first else {
            return nil
        }
        guard let week = seed.week else {
            throw SyncableError.missingProperty(#keyPath(SessionObject.week))
        }

        let batchReq = SessionObject.fetchRequest()
        batchReq.predicate = NSPredicate(format: "isSynced == false AND week == %@", week as NSDate)

        let rows = try context.fetch(batchReq)

        return SyncGroup(
            recordType: "DateIntMatrix",
            name: "Session",
            date: week,
            batch: rows,
            fields: rows.grouped(by: \.date).mapValues(\.count)
        )
    }
}
