//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension MetricsObject {
    static func group<T: MetricsObject & Syncable>(in context: NSManagedObjectContext) throws
        -> SyncGroup<T>?
    {
        let entityName = String(describing: T.self)

        let seedReq = NSFetchRequest<T>(entityName: entityName)
        seedReq.predicate = NSPredicate(format: "isSynced == false")
        seedReq.fetchLimit = 1

        guard let seed = try context.fetch(seedReq).first else {
            return nil
        }
        guard let name = seed.name else {
            throw SyncableError.missingProperty("name")
        }
        guard let telemetry = seed.telemetry else {
            throw SyncableError.missingProperty("telemetry")
        }
        guard let week = seed.week else {
            throw SyncableError.missingProperty("week")
        }

        let batchReq = NSFetchRequest<T>(entityName: entityName)
        batchReq.predicate = NSPredicate(
            format: "isSynced == false AND name == %@ AND telemetry == %@ AND week == %@",
            name,
            telemetry,
            week as NSDate
        )

        let batch = try context.fetch(batchReq)

        return SyncGroup(
            recordType: T.Value.Value.recordName,
            name: "\(name)_\(telemetry)",
            date: week,
            representables: nil,
            batch: batch,
        )
    }
}
