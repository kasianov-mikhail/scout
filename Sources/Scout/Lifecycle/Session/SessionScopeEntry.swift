//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(SessionScopeEntry)
package class SessionScopeEntry: SyncableEntry {
    @NSManaged var session: SessionEntry?
    @NSManaged var launch: LaunchEntry?

    var sessionID: UUID? {
        session?.sessionID
    }

    var launchID: UUID? {
        owner?.launchID
    }

    var installID: UUID? {
        owner?.installID
    }

    var deviceID: UUID? {
        owner?.deviceID
    }

    private var owner: LaunchEntry? {
        session?.launch ?? launch
    }

    func sessionRecord(type: String, id: String) -> Record {
        var record = Record(recordType: type, recordID: id)

        record["date"] = date
        record["session_id"] = sessionID?.uuidString
        record["launch_id"] = launchID?.uuidString
        record["install_id"] = installID?.uuidString
        record["device_id"] = deviceID?.uuidString

        record.setValues(metadata)

        return record
    }
}
