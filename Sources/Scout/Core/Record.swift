//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

/// Converts an `EventModel` instance to a `CKRecord` for CloudKit storage.
///
/// This function takes an `EventModel` object and creates a new `CKRecord`
/// with the corresponding fields populated from the event.
///
/// - Parameter event: The `EventModel` instance to convert.
/// - Returns: A `CKRecord` populated with the event's data.
///
/// Note: The `version` field is set to 1 to indicate the initial version of the record.
/// This can be useful for handling migrations or updates to the record schema in the future.
///
func toRecord(event: EventModel) -> CKRecord {
    let record = CKRecord(recordType: "Event")

    record["params"] = event.params
    record["param_count"] = event.paramCount
    record["name"] = event.name
    record["level"] = event.level
    record["date"] = event.date
    record["hour"] = event.hour
    record["week"] = event.week
    record["uuid"] = event.uuid?.uuidString
    record["version"] = 1
    record["user_id"] = event.userID?.uuidString
    record["session_id"] = event.sessionID?.uuidString

    return record
}
