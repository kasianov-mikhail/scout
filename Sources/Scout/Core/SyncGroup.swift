//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData

/// A structure representing a synchronization group.
///
/// `SyncGroup` is used to group events and related fields for a specific week.
///
struct SyncGroup: Equatable, @unchecked Sendable {

    /// The name of the synchronization group.
    let name: String

    /// The date representing the week of the synchronization group.
    let week: Date

    /// An array of Core Data object IDs associated with the synchronization group.
    let objectIDs: [NSManagedObjectID]

    /// An array of `CKRecord` objects associated with the synchronization group.
    let records: [CKRecord]

    /// A dictionary mapping field names to their corresponding count values.
    var fields: [String: Int] {
        Dictionary(grouping: records, by: \.hourField).mapValues(\.count)
    }
}

extension SyncGroup {

    /// Initializes a new instance of `SyncGroup`.
    ///
    /// This initializer also groups the events by their `hour` field and counts the occurrences,
    /// storing the result in the `fields` property.
    /// 
    init(name: String, week: Date, events: [EventModel]) {
        self.name = name
        self.week = week
        self.objectIDs = events.map(\.objectID)
        self.records = events.map(CKRecord.init)
    }
}

extension SyncGroup {

    /// Fetches the most recent `EventModel` from the given `NSManagedObjectContext` and uses its
    /// `name` and `week` properties to find all events that match these criteria. It then groups
    /// the events by their `hour`'s `field` property and counts the occurrences of each field.
    ///
    /// - Parameter context: The `NSManagedObjectContext` to fetch the events from.
    /// - Returns: A `SyncGroup` containing the name, week, events, and fields, or `nil` if no events are found.
    /// - Throws: An error if the fetch request fails.
    ///
    static func group(in context: NSManagedObjectContext) throws -> SyncGroup? {
        let eventRequest = EventModel.fetchRequest()
        eventRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
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

        return SyncGroup(name: name, week: week, events: events)
    }
}

// MARK: - Matrix Operations

extension SyncGroup {

    /// Creates a new `CKRecord` instance representing a matrix.
    ///
    /// The matrix will include the `name` and `week` properties of the `SyncGroup`.
    ///
    /// - Returns: A new `CKRecord` instance.
    ///
    func newMatrix() -> CKRecord {
        let matrix = CKRecord(recordType: "DateIntMatrix")
        matrix["name"] = name
        matrix["date"] = week
        return matrix
    }

    /// Asynchronously retrieves a CKRecord from the specified database or creates a new one if the database doesn't contain a required matrix.
    ///
    /// - Parameter database: The database conforming to `Database` from which to retrieve the CKRecord.
    /// - Returns: A `CKRecord` retrieved from the specified database or a newly created one.
    /// - Throws: An error if the operation fails.
    ///
    func matrix(in database: Database) async throws -> CKRecord {
        let namePredicate = NSPredicate(format: "name == %@", name)
        let datePredicate = NSPredicate(format: "date == %@", week as NSDate)
        let predicate = NSCompoundPredicate(
            type: .and, subpredicates: [namePredicate, datePredicate])

        let query = CKQuery(recordType: "DateIntMatrix", predicate: predicate)
        let desiredKeys = fields.map(\.key)

        let allMatrices = try await database.allRecords(matching: query, desiredKeys: desiredKeys)
        let matrix = allMatrices.randomElement() ?? newMatrix()

        return matrix
    }
}
