//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData

// MARK: - Syncable protocol

/// Core Data models that can be synchronized as small, logical batches.
///
/// Contract:
/// - `group(in:)` returns **one** batch (or `nil` if nothing pending).
/// - Implementations are free to choose the grouping key (e.g. week/name).
/// - Keep batches small (use a seed row + its key to collect the set).
///
protocol Syncable: NSManagedObject {

    /// Returns a batch of currently-unsynced objects, or `nil` if none.
    ///
    /// Implementations should:
    /// - use one “seed” unsynced row to determine the batch key,
    /// - fetch the rest of the unsynced rows matching that key,
    /// - map them into `SyncGroup`.
    ///
    static func group(in context: NSManagedObjectContext) throws -> SyncGroup?

    /// Whether this instance has been sent upstream.
    var isSynced: Bool { get set }
}

// MARK: - Errors

/// Errors for missing required fields when building a batch.
///
enum SyncableError: Error {
    case missingProperty(String)

    var localizedDescription: String {
        switch self {
        case let .missingProperty(property):
            return "Missing property: \(property). Cannot group objects."
        }
    }
}

// MARK: - EventObject

extension EventObject: Syncable {

    /// One batch of unsynced events sharing `(name, week)`, grouped by `hour`.
    ///
    /// Strategy:
    /// - Seed = most recent unsynced event (via `fetchLimit = 1`).
    /// - Batch key = `(name, week)` from seed.
    /// - Fields = counts grouped by `hour` (for "DateIntMatrix").
    ///
    static func group(in context: NSManagedObjectContext) throws -> SyncGroup? {
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

// MARK: - SessionObject

extension SessionObject: Syncable {

    /// One batch of unsynced sessions for a `week`, grouped by `date`.
    ///
    /// Strategy:
    /// - Seed = most recent unsynced session.
    /// - Batch key = `week`.
    /// - Fields = counts grouped by `date` (for "DateIntMatrix").
    ///
    static func group(in context: NSManagedObjectContext) throws -> SyncGroup? {
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

// MARK: - UserActivity

extension UserActivity: Syncable {

    /// One batch of unsynced activities for a `month`, mapped via `matrix` to (key, count).
    ///
    /// Strategy:
    /// - Seed = most recent unsynced activity.
    /// - Batch key = `month`.
    /// - Fields = `"cell_<periodShort>_<dayIndex>" -> count` (for "PeriodMatrix").
    ///
    static func group(in context: NSManagedObjectContext) throws -> SyncGroup? {
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

// MARK: - MetricsObject

extension MetricsObject: Syncable {

    /// One batch of unsynced metrics sharing `(name, week)`, grouped by `hour` with `Double` payloads.
    ///
    /// Strategy:
    /// - Seed = most recent unsynced metrics row.
    /// - Batch key = `(name, week)`.
    /// - Fields = counts grouped by `hour` (for "DateDoubleMatrix").
    ///
    static func group(in context: NSManagedObjectContext) throws -> SyncGroup? {
        let seedReq = NSFetchRequest<MetricsObject>(entityName: "MetricsObject")
        seedReq.predicate = NSPredicate(format: "isSynced == false")
        seedReq.fetchLimit = 1

        guard let seed = try context.fetch(seedReq).first else {
            return nil
        }
        guard let name = seed.name else {
            throw SyncableError.missingProperty(#keyPath(MetricsObject.name))
        }
        guard let week = seed.week else {
            throw SyncableError.missingProperty(#keyPath(MetricsObject.week))
        }

        let batchReq = NSFetchRequest<MetricsObject>(entityName: "MetricsObject")
        batchReq.predicate = NSPredicate(
            format: "isSynced == false AND name == %@ AND week == %@",
            name,
            week as NSDate
        )

        let rows = try context.fetch(batchReq)

        return SyncGroup(
            recordType: "DateDoubleMatrix",
            name: name,
            date: week,
            objects: rows,
            fields: rows.grouped(by: \.hour)
        )
    }
}
