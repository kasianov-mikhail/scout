//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

func metricsGroup<T: MatrixValue>(
    in context: NSManagedObjectContext,
    valuePath: KeyPath<T.Object, T>
) throws -> SyncGroup<T>? {
    let entityName = String(describing: T.Object.self)

    let seedReq = NSFetchRequest<T.Object>(entityName: entityName)
    seedReq.predicate = NSPredicate(format: "isSynced == false")
    seedReq.fetchLimit = 1

    guard let seed = try context.fetch(seedReq).first else {
        return nil
    }
    guard let name = seed.name else {
        throw SyncableError.missingProperty("name")
    }
    guard let telemetryValue = seed.telemetry else {
        throw SyncableError.missingProperty("telemetry")
    }
    guard let week = seed.week else {
        throw SyncableError.missingProperty("week")
    }

    let batchReq = NSFetchRequest<T.Object>(entityName: entityName)
    batchReq.predicate = NSPredicate(
        format: "isSynced == false AND name == %@ AND telemetry == %@ AND week == %@",
        name,
        telemetryValue,
        week as NSDate
    )

    let batch = try context.fetch(batchReq).grouped(by: \.hour)

    let fields = batch.mapValues { items in
        items.reduce(T.zero) { $0 + $1[keyPath: valuePath] }
    }

    return SyncGroup(
        recordType: T.recordName,
        name: "\(name)_\(telemetryValue)",
        date: week,
        objects: [],
        fields: fields
    )
}
