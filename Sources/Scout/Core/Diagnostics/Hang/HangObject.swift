//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(HangObject)
final class HangObject: IncidentObject, HasSession {
    static let recordType = "Hang"

    @NSManaged var session: SessionObject?
    @NSManaged var hangID: UUID
    @NSManaged var duration: Double
}

extension HangObject: RecordEncodable {
    var record: Record {
        var record = incident(type: Self.recordType, id: hangID)
        record["duration"] = duration
        return record
    }
}
