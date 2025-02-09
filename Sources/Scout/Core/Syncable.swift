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

// MARK: - EventModel

extension EventModel: Syncable {

    /// Fetches the most recent `EventModel` from the given `NSManagedObjectContext` and uses its
    /// `name` and `week` properties to find all events that match these criteria. It then groups
    /// the events by their `hour`'s `field` property and counts the occurrences of each field.
    ///
    static func group(in context: NSManagedObjectContext) throws -> SyncGroup? {
        let eventRequest = EventModel.fetchRequest()
        eventRequest.fetchLimit = 1

        guard let event = try context.fetch(eventRequest).first else {
            return nil
        }
        guard let name = event.name else {
            throw SyncableError.missingProperty(#keyPath(EventModel.name))
        }
        guard let week = event.week else {
            throw SyncableError.missingProperty(#keyPath(EventModel.week))
        }

        let groupRequest = EventModel.fetchRequest()
        groupRequest.predicate = NSPredicate(
            format: "name == %@ AND week == %@", name, week as NSDate)

        let events = try context.fetch(groupRequest)

        return SyncGroup(
            name: name,
            date: week,
            objects: events,
            fields: events.grouped(by: \.hour)
        )
    }
}

// MARK: - Session

extension Session: Syncable {

    /// Fetches the most recent `Session` from the given `NSManagedObjectContext` and uses its
    /// `week` property to find all sessions that match this criteria. It then groups
    /// the sessions by their `name` and `week` properties.
    ///
    static func group(in context: NSManagedObjectContext) throws -> SyncGroup? {
        let sessionRequest = Session.fetchRequest()
        sessionRequest.predicate = NSPredicate(format: "endDate != nil")
        sessionRequest.fetchLimit = 1

        guard let session = try context.fetch(sessionRequest).first else {
            return nil
        }
        guard let week = session.week else {
            throw SyncableError.missingProperty(#keyPath(Session.week))
        }

        let groupRequest = Session.fetchRequest()
        groupRequest.predicate = NSPredicate(format: "week == %@", week as NSDate)

        let sessions = try context.fetch(groupRequest)

        return SyncGroup(
            name: "Session",
            date: week,
            objects: sessions,
            fields: sessions.grouped(by: \.hour)
        )
    }
}

// MARK: - Grouping

extension Array {

    /// Groups the elements of the collection by a specified date key path and returns a dictionary
    /// where the keys are strings representing the combination of the weekday and hour components
    /// of the date, and the values are the counts of elements in each group.
    /// 
    /// - Parameter keyPath: A key path to the date property of the elements.
    /// - Returns: A dictionary where the keys are strings in the format `cell_<weekday>_<hour>`
    ///   and the values are the counts of elements in each group.
    ///
    fileprivate func grouped(by keyPath: KeyPath<Element, Date?>) -> [String: Int] {
        Dictionary(grouping: self) {
            $0[keyPath: keyPath]
        }
        .reduce(into: [:]) { result, pair in
            if let key = pair.key {
                let week = Calendar.UTC.component(.weekday, from: key)
                let hour = Calendar.UTC.component(.hour, from: key)
                let components = ["cell", String(week), String(format: "%02d", hour)]
                let joined = components.joined(separator: "_")

                result[joined] = pair.value.count
            }
        }
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
            name: "ActiveUser",
            date: month,
            objects: activities,
            fields: Dictionary(uniqueKeysWithValues: activities.compactMap(\.matrix))
        )
    }

    private var matrix: (String, Int)? {
        guard let month, let day else {
            return nil
        }
        guard let rawPeriod = period, let period = ActivityPeriod(rawValue: rawPeriod) else {
            return nil
        }

        let days = Calendar.UTC.dateComponents([.day], from: month, to: day).day ?? 0
        let components = ["cell", period.rawValue.lowercased(), String(format: "%02d", days)]
        let joined = components.joined(separator: "_")
        let count = self[keyPath: period.countField]

        return (joined, Int(count))
    }
}
