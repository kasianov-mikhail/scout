//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(EventEntry)
package final class EventEntry: SyncableEntry, HasSession {
    package static let recordType = "Event"

    @NSManaged var session: SessionEntry?
    @NSManaged var name: String?
    @NSManaged var eventID: UUID
    @NSManaged var level: String?
    @NSManaged var paramCount: Int64
    @NSManaged var params: Data?
}

extension EventEntry: RecordEncodable {
    package var record: Record {
        var record = sessionRecord(type: Self.recordType, id: eventID.uuidString)

        record["name"] = name
        record["level"] = level
        record["params"] = params
        record["param_count"] = paramCount
        record["uuid"] = eventID.uuidString

        return record
    }
}
