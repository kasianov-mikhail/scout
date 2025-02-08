//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData

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
            objectIDs: sessions.map(\.objectID),
            fields: sessions.grouped(by: \.hour)
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
