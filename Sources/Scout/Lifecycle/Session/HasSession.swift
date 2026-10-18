//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

protocol HasSession {
    var session: SessionEntry? { get }
}

extension HasSession {
    var sessionID: UUID? {
        session?.sessionID
    }

    var launchID: UUID? {
        session?.launchID
    }

    var installID: UUID? {
        session?.installID
    }

    var deviceID: UUID? {
        session?.deviceID
    }
}

extension HasSession where Self: DateEntry {
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
