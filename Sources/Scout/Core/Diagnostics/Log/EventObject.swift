//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(EventObject)
final class EventObject: SyncableObject, HasSession {
    static let recordType = "Event"

    @NSManaged var session: SessionObject?
    @NSManaged var name: String?
    @NSManaged var eventID: UUID
    @NSManaged var level: String?
    @NSManaged var paramCount: Int64
    @NSManaged var params: Data?
}

extension EventObject: RecordEncodable {
    var record: Record {
        var record = Record(recordType: Self.recordType, recordID: eventID.uuidString)

        record["name"] = name
        record["level"] = level
        record["params"] = params
        record["param_count"] = paramCount
        record["date"] = date
        record["uuid"] = eventID.uuidString
        record["session_id"] = sessionID?.uuidString
        record["launch_id"] = launchID?.uuidString
        record["install_id"] = installID?.uuidString
        record["device_id"] = deviceID?.uuidString

        record.setValues(metadata)

        return record
    }
}
