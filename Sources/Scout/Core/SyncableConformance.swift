//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension EventObject: Syncable {
    static func group(in context: NSManagedObjectContext) throws -> SyncGroup<Int>? {
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

        let rows = try context.fetch(batchReq)

        return SyncGroup(
            recordType: "DateIntMatrix",
            name: name,
            date: week,
            objects: rows,
            fields: rows.grouped(by: \.hour)
        )
    }
}

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
            objects: rows,
            fields: rows.grouped(by: \.date)
        )
    }
}

extension UserActivity: Syncable {
    static func group(in context: NSManagedObjectContext) throws -> SyncGroup<Int>? {
        let seedReq = UserActivity.fetchRequest()
        seedReq.predicate = NSPredicate(format: "isSynced == false")
        seedReq.fetchLimit = 1

        guard let seed = try context.fetch(seedReq).first else {
            return nil
        }
        guard let month = seed.month else {
            throw SyncableError.missingProperty(#keyPath(UserActivity.month))
        }

        let batchReq = UserActivity.fetchRequest()
        batchReq.predicate = NSPredicate(
            format: "isSynced == false AND month == %@",
            month as NSDate
        )

        let rows = try context.fetch(batchReq)

        return SyncGroup(
            recordType: "PeriodMatrix",
            name: "ActiveUser",
            date: month,
            objects: rows,
            fields: Dictionary(uniqueKeysWithValues: rows.compactMap(\.matrix))
        )
    }

    /// Maps the row to a matrix `(key, count)` pair; returns `nil` if data is incomplete.
    ///
    private var matrix: (String, Int)? {
        guard let month, let day else {
            return nil
        }
        guard let raw = period, let period = ActivityPeriod(rawValue: raw) else {
            return nil
        }

        let d = Calendar.UTC.dateComponents([.day], from: month, to: day).day ?? 0
        let key = ["cell", period.rawValue, String(format: "%02d", d + 1)].joined(separator: "_")
        let count = self[keyPath: period.countField]

        return (key, Int(count))
    }
}

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
            fields: [:]// rows.grouped(by: \.hour)
        )
    }
}
