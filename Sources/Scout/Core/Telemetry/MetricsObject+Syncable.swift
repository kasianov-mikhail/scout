// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension IntMetricsObject: Syncable {
    static func group(in context: NSManagedObjectContext) throws -> SyncGroup<Int>? {
        let seedReq = NSFetchRequest<IntMetricsObject>(entityName: "IntMetricsObject")
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
        guard let telemetry = Telemetry.Export(rawValue: telemetryValue) else {
            throw Telemetry.ExportError.invalidName
        }
        guard let week = seed.week else {
            throw SyncableError.missingProperty("week")
        }

        let batchReq = NSFetchRequest<IntMetricsObject>(entityName: "IntMetricsObject")
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
            objects: [],
            fields: rows.grouped(by: \.hour).mapValues {
                $0.reduce(0) { $0 + Int($1.intValue) }
            }
        )
    }
}

extension DoubleMetricsObject: Syncable {
    static func group(in context: NSManagedObjectContext) throws -> SyncGroup<Double>? {
        let seedReq = NSFetchRequest<DoubleMetricsObject>(entityName: "DoubleMetricsObject")
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
        guard let telemetry = Telemetry.Export(rawValue: telemetryValue) else {
            throw Telemetry.ExportError.invalidName
        }
        guard let week = seed.week else {
            throw SyncableError.missingProperty("week")
        }

        let batchReq = NSFetchRequest<DoubleMetricsObject>(entityName: "DoubleMetricsObject")
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
            objects: [],
            fields: rows.grouped(by: \.hour).mapValues {
                $0.reduce(0) { $0 + $1.doubleValue }
            }
        )
    }
}
