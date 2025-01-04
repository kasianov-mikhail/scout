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
protocol Syncable {

    /// Groups the objects of the conforming type by their properties.
    static func group(in context: NSManagedObjectContext) throws -> SyncGroup?
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
        guard let name = event.name, let week = event.week else {
            return nil
        }

        let groupRequest = EventModel.fetchRequest()
        groupRequest.predicate = NSPredicate(
            format: "name == %@ AND week == %@", name, week as NSDate)

        let events = try context.fetch(groupRequest)

        return SyncGroup(
            name: name,
            week: week,
            objectIDs: events.map(\.objectID),
            records: events.map(CKRecord.init)
        )
    }
}

extension CKRecord {

    /// Initializes a new `CKRecord` instance with the specified `EventModel`.
    ///
    /// This convenience initializer populates the record fields with the event data.
    /// The `version` field is set to 1 to indicate the initial version of the record.
    /// This can be useful for handling migrations or updates to the record schema in the future.
    ///
    fileprivate convenience init(event: EventModel) {
        self.init(recordType: "Event")

        self["name"] = event.name
        self["level"] = event.level
        self["params"] = event.params
        self["param_count"] = event.paramCount

        self["date"] = event.date
        self["hour"] = event.hour
        self["week"] = event.week

        self["uuid"] = event.uuid?.uuidString
        self["session_id"] = event.sessionID?.uuidString
        self["launch_id"] = event.launchID?.uuidString
        self["user_id"] = event.userID?.uuidString

        self["version"] = 1
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
            return nil
        }

        let groupRequest = Session.fetchRequest()
        groupRequest.predicate = NSPredicate(format: "week == %@", week as NSDate)

        let sessions = try context.fetch(groupRequest)

        return SyncGroup(
            name: "Session",
            week: week,
            objectIDs: sessions.map(\.objectID),
            records: sessions.map(CKRecord.init)
        )
    }
}

extension CKRecord {

    /// Initialize a record with a session.
    ///
    /// This convenience initializer populates the record fields with the session data.
    /// The `version` field is set to 1 to indicate the initial version of the record.
    /// This can be useful for handling migrations or updates to the record schema in the future.
    ///
    fileprivate convenience init(session: Session) {
        self.init(recordType: "Session")

        self["start_date"] = session.startDate
        self["end_date"] = session.endDate
        self["hour"] = session.hour
        self["week"] = session.week

        self["session_id"] = session.sessionID?.uuidString
        self["launch_id"] = session.launchID?.uuidString
        self["user_id"] = session.userID?.uuidString

        self["version"] = 1
    }
}
