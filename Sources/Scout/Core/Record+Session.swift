//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

extension CKRecord {

    /// Initialize a record with a session.
    convenience init(session: Session) {
        self.init(recordType: "Session")
        self["start_date"] = session.startDate
        self["end_date"] = session.endDate
        self["user_id"] = session.userID as? CKRecordValue
        self["launch_id"] = session.launchID as? CKRecordValue
        self["session_id"] = session.sessionID as? CKRecordValue
        self["version"] = 1
    }
}
