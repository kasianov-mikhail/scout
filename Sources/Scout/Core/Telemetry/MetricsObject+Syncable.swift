//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension MetricsObject: Syncable {
    static func group(in context: NSManagedObjectContext) throws -> SyncGroup<Double>? {
        let seedReq = NSFetchRequest<MetricsObject>(entityName: "MetricsObject")
        seedReq.predicate = NSPredicate(format: "isSynced == false")
        seedReq.fetchLimit = 1

        guard let seed = try context.fetch(seedReq).first else {
            return nil
        }
        guard let name = seed.name else {
            throw SyncableError.missingProperty(#keyPath(MetricsObject.name))
        }
        guard let telemetryValue = seed.telemetry else {
            throw SyncableError.missingProperty(#keyPath(MetricsObject.telemetry))
        }
        guard let telemetry = Telemetry.Export(rawValue: telemetryValue) else {
            throw Telemetry.ExportError.invalidName
        }
        guard let week = seed.week else {
            throw SyncableError.missingProperty(#keyPath(MetricsObject.week))
        }

        let batchReq = NSFetchRequest<MetricsObject>(entityName: "MetricsObject")
        batchReq.predicate = NSPredicate(
            format: "isSynced == false AND name == %@ AND telemetry == %@ AND week == %@",
            name,
            telemetryValue,
            week as NSDate
        )

        let rows = try context.fetch(batchReq)

        return SyncGroup(
            recordType: telemetry.recordType,
            name: "\(name)_\(telemetryValue)",
            date: week,
            objects: rows,
            fields: [:]  // rows.grouped(by: \.hour)
        )
    }
}
