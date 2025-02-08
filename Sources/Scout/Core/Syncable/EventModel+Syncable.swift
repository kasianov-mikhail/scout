//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData

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
            objectIDs: events.map(\.objectID),
            fields: events.grouped(by: \.hour)
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

        self["uuid"] = event.eventID?.uuidString
        self["session_id"] = event.sessionID?.uuidString
        self["launch_id"] = event.launchID?.uuidString
        self["user_id"] = event.userID?.uuidString

        self["version"] = 1
    }
}
