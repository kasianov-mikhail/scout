//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

/// A protocol that defines a type that can be represented as a `CKRecord`.
protocol CKRepresentable {

    /// A computed property that returns a `CKRecord` representation of the instance.
    var toRecord: CKRecord { get }
}

// MARK: - EventModel

extension EventModel: CKRepresentable {

    /// A computed property that returns a `CKRecord` representation of the `EventModel` instance.
    ///
    /// This property creates a new `CKRecord` with the record type "Event" and sets its fields
    /// based on the properties of the `EventModel` instance.
    ///
    var toRecord: CKRecord {
        let record = CKRecord(recordType: "Event")

        record["name"] = name
        record["level"] = level
        record["params"] = params
        record["param_count"] = paramCount

        record["date"] = date
        record["hour"] = hour
        record["week"] = week

        record["uuid"] = eventID?.uuidString
        record["session_id"] = sessionID?.uuidString
        record["launch_id"] = launchID?.uuidString
        record["user_id"] = userID?.uuidString

        record["version"] = 1

        return record
    }
}

// MARK: - Session

extension Session: CKRepresentable {

    /// A computed property that returns a `CKRecord` representation of the `Session` instance.
    ///
    /// This property creates a new `CKRecord` with the record type "Session" and sets its fields
    /// based on the properties of the `Session` instance.
    ///
    var toRecord: CKRecord {
        let record = CKRecord(recordType: "Session")

        record["start_date"] = startDate
        record["end_date"] = endDate
        record["hour"] = hour
        record["week"] = week

        record["session_id"] = sessionID?.uuidString
        record["launch_id"] = launchID?.uuidString
        record["user_id"] = userID?.uuidString

        record["version"] = 1

        return record
    }
}
