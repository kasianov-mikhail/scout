//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(ResourceEntry)
package final class ResourceEntry: IncidentEntry, HasSession, KeyedIncident {
    package static let recordType = "ResourceException"
    static let idKey = "resourceID"

    @NSManaged var session: SessionEntry?
    @NSManaged var resourceID: UUID
    @NSManaged var kind: String
    @NSManaged var value: Double
}

extension ResourceEntry: RecordEncodable {
    package var record: Record {
        var record = incident(type: Self.recordType, id: resourceID)
        record["category"] = kind
        record["value"] = value
        return record
    }
}
