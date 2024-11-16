//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

extension CKRecord {

    /// Initializes a new `CKRecord` instance with the specified `EventModel`.
    ///
    /// This convenience initializer populates the record fields with the event data.
    /// The `version` field is set to 1 to indicate the initial version of the record.
    /// This can be useful for handling migrations or updates to the record schema in the future.
    ///
    /// - Parameter event: The `EventModel` instance to use for populating the record.
    /// - Returns: A new `CKRecord` instance populated with the event data.
    ///
    convenience init(event: EventModel) {
        self.init(recordType: "Event")

        self["params"] = event.params
        self["param_count"] = event.paramCount
        self["name"] = event.name
        self["level"] = event.level
        self["date"] = event.date
        self["hour"] = event.hour
        self["week"] = event.week
        self["uuid"] = event.uuid?.uuidString
        self["version"] = 1
        self["user_id"] = event.userID?.uuidString
        self["session_id"] = event.sessionID?.uuidString
    }
}
