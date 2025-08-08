//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData

/// A protocol for types that can be synchronized. Types conforming to `Syncable` can be grouped
/// by their properties and counted. This is useful for synchronizing data between a local
/// Core Data context and a remote CloudKit database.
///
protocol Syncable: NSManagedObject {

    /// Groups the objects of the conforming type by their properties.
    static func group(in context: NSManagedObjectContext) throws -> SyncGroup?

    var isSynced: Bool { set get }
}

// MARK: - Random grouping

extension [Syncable.Type] {

    /// Groups the array of `Syncable` types by their properties.
    func group(in context: NSManagedObjectContext) throws -> SyncGroup? {

        // Shuffle the array to avoid grouping the same types in the same order every time.
        for syncable in shuffled() {
            if let group = try syncable.group(in: context) {
                return group
            }
        }

        return nil
    }
}

// MARK: - Error

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

    /// Fetches the most recent `EventObject` from the given `NSManagedObjectContext` and uses its
    /// `name` and `week` properties to find all events that match these criteria. It then groups
    /// the events by their `hour`'s `field` property and counts the occurrences of each field.
    ///
    static func group(in context: NSManagedObjectContext) throws -> SyncGroup? {
        let eventRequest = NSFetchRequest<EventObject>(entityName: "EventObject")
        eventRequest.predicate = NSPredicate(format: "isSynced == false")
        eventRequest.fetchLimit = 1

        guard let event = try context.fetch(eventRequest).first else {
            return nil
        }
        guard let name = event.name else {
            throw SyncableError.missingProperty(#keyPath(EventObject.name))
        }
        guard let week = event.week else {
            throw SyncableError.missingProperty(#keyPath(EventObject.week))
        }

        let groupRequest = NSFetchRequest<EventObject>(entityName: "EventObject")
        groupRequest.predicate = NSPredicate(
            format: "isSynced == false AND name == %@ AND week == %@",
            name,
            week as NSDate
        )

        let events = try context.fetch(groupRequest)

        return SyncGroup(
            recordType: "DateIntMatrix",
            name: name,
            date: week,
            objects: events,
            fields: events.grouped(by: \.hour)
        )
    }
}

// MARK: - SessionObject

extension SessionObject: Syncable {

    /// Fetches the most recent `Session` from the given `NSManagedObjectContext` and uses its
    /// `week` property to find all sessions that match this criteria. It then groups
    /// the sessions by their `name` and `week` properties.
    ///
    static func group(in context: NSManagedObjectContext) throws -> SyncGroup? {
        let sessionRequest = SessionObject.fetchRequest()
        sessionRequest.predicate = NSPredicate(format: "isSynced == false")
        sessionRequest.fetchLimit = 1

        guard let session = try context.fetch(sessionRequest).first else {
            return nil
        }
        guard let week = session.week else {
            throw SyncableError.missingProperty(#keyPath(SessionObject.week))
        }

        let groupRequest = SessionObject.fetchRequest()
        groupRequest.predicate = NSPredicate(
            format: "isSynced == false AND week == %@",
            week as NSDate
        )

        let sessions = try context.fetch(groupRequest)

        return SyncGroup(
            recordType: "DateIntMatrix",
            name: "Session",
            date: week,
            objects: sessions,
            fields: sessions.grouped(by: \.date)
        )
    }
}

// MARK: - UserActivity

extension UserActivity: Syncable {

    /// Fetches the most recent `UserActivity` from the given `NSManagedObjectContext` and uses its
    /// `month` property to find all activities that match this criteria. It then groups
    /// the activities by their `month` property.
    ///
    static func group(in context: NSManagedObjectContext) throws -> SyncGroup? {
        let activityRequest = UserActivity.fetchRequest()
        activityRequest.predicate = NSPredicate(format: "isSynced == false")
        activityRequest.fetchLimit = 1

        guard let activity = try context.fetch(activityRequest).first else {
            return nil
        }
        guard let month = activity.month else {
            throw SyncableError.missingProperty(#keyPath(UserActivity.month))
        }

        let groupRequest = UserActivity.fetchRequest()

        groupRequest.predicate = NSPredicate(
            format: "isSynced == false && month == %@",
            month as NSDate
        )

        let activities = try context.fetch(groupRequest)

        return SyncGroup(
            recordType: "PeriodMatrix",
            name: "ActiveUser",
            date: month,
            objects: activities,
            fields: Dictionary(uniqueKeysWithValues: activities.compactMap(\.matrix))
        )
    }

    /// A computed property that returns a tuple containing a string key and an integer count.
    /// The key is a combination of the period's short title and the number of days from the month
    /// to the day. The count is the value of the period's count field.
    ///
    private var matrix: (String, Int)? {
        guard let month, let day else {
            return nil
        }
        guard let rawPeriod = period, let period = ActivityPeriod(rawValue: rawPeriod) else {
            return nil
        }

        let days = Calendar.UTC.dateComponents([.day], from: month, to: day).day ?? 0
        let components = ["cell", period.rawValue, String(format: "%02d", days + 1)]
        let joined = components.joined(separator: "_")
        let count = self[keyPath: period.countField]

        return (joined, Int(count))
    }
}

extension MetricsObject: Syncable {

    static func group(in context: NSManagedObjectContext) throws -> SyncGroup? {
        let metricsRequest = NSFetchRequest<EventObject>(entityName: "MetricsObject")
        metricsRequest.predicate = NSPredicate(format: "isSynced == false")
        metricsRequest.fetchLimit = 1

        guard let metricsItem = try context.fetch(metricsRequest).first else {
            return nil
        }
        guard let name = metricsItem.name else {
            throw SyncableError.missingProperty(#keyPath(MetricsObject.name))
        }
        guard let week = metricsItem.week else {
            throw SyncableError.missingProperty(#keyPath(MetricsObject.week))
        }

        let groupRequest = NSFetchRequest<MetricsObject>(entityName: "MetricsObject")
        groupRequest.predicate = NSPredicate(
            format: "isSynced == false AND name == %@ AND week == %@",
            name,
            week as NSDate
        )

        let allMetrics = try context.fetch(groupRequest)

        return SyncGroup(
            recordType: "DateDoubleMatrix",
            name: name,
            date: week,
            objects: allMetrics,
            fields: allMetrics.grouped(by: \.hour)
        )
    }
}
