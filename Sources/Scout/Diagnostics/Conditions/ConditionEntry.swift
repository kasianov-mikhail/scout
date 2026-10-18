//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(ConditionEntry)
package final class ConditionEntry: SyncableEntry, HasSession {
    package static let recordType = "Condition"

    @NSManaged var session: SessionEntry?
    @NSManaged var conditionID: UUID
    @NSManaged var kind: String
    @NSManaged var value: Double
}

extension ConditionEntry: RecordEncodable {
    package var record: Record {
        var record = sessionRecord(type: Self.recordType, id: conditionID.uuidString)

        record["category"] = kind
        record["value"] = value
        record["uuid"] = conditionID.uuidString
        record["app_version"] = session?.appVersion

        return record
    }
}
