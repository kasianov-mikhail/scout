//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(HangEntry)
package final class HangEntry: IncidentEntry, HasSession {
    package static let recordType = "Hang"

    @NSManaged var session: SessionEntry?
    @NSManaged var hangID: UUID
    @NSManaged var duration: Double
}

extension HangEntry: RecordEncodable {
    package var record: Record {
        var record = incident(type: Self.recordType, id: hangID)
        record["duration"] = duration
        return record
    }
}
