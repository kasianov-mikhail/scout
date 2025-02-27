//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

/// A protocol that defines a type that can be represented as a `CKRecord`.
///
/// Types that conform to the `CKRepresentable` protocol can be converted to a `CKRecord`
/// representation, which can be saved to a CloudKit database.
///
protocol CKRepresentable {

    /// A computed property that returns a `CKRecord` representation of the instance.
    ///
    /// This property should create a new `CKRecord` with the appropriate record type and set
    /// its fields based on the properties of the instance. The `CKRecord` should be returned
    /// as the result of this property. For example:
    /// ```
    /// var toRecord: CKRecord {
    ///    let record = CKRecord(recordType: "MyRecordType")
    ///    record["field1"] = field1
    ///    record["field2"] = field2
    ///    return record
    /// }
    /// ```
    ///
    var toRecord: CKRecord { get }
}

// MARK: - EventModel

extension EventObject: CKRepresentable {

    /// A computed property that returns a `CKRecord` representation of the `EventObject` instance.
    ///
    /// This property creates a new `CKRecord` with the record type "Event" and sets its fields
    /// based on the properties of the `EventObject` instance.
    ///
    var toRecord: CKRecord {
        let record = CKRecord(recordType: "Event")

        record["name"] = name
        record["level"] = level
        record["params"] = params
        record["param_count"] = paramCount

        record["date"] = date
        record.setValuesForKeys(dateFields)

        record["uuid"] = eventID?.uuidString
        record["session_id"] = sessionID?.uuidString
        record["launch_id"] = launchID?.uuidString
        record["user_id"] = userID?.uuidString

        record["version"] = 1

        return record
    }
}

// MARK: - Session

extension SessionObject: CKRepresentable {

    /// A computed property that returns a `CKRecord` representation of the `SessionObject` instance.
    ///
    /// This property creates a new `CKRecord` with the record type "Session" and sets its fields
    /// based on the properties of the `SessionObject` instance.
    ///
    var toRecord: CKRecord {
        let record = CKRecord(recordType: "Session")

        record["start_date"] = date
        record["end_date"] = endDate
        record.setValuesForKeys(dateFields)

        record["session_id"] = sessionID?.uuidString
        record["launch_id"] = launchID?.uuidString
        record["user_id"] = userID?.uuidString

        record["version"] = 1

        return record
    }
}
