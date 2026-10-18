//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(ScreenEntry)
package final class ScreenEntry: ObservationEntry {
    package static let recordType = "Screen"

    @NSManaged var screenID: UUID
    @NSManaged var name: String
    @NSManaged var previous: String?
    @NSManaged var endDate: Date?

    override var latest: Date? {
        endDate ?? datePrimitive
    }

    override var isPurgeable: Bool {
        endDate != nil
    }
}

extension ScreenEntry: RecordEncodable {
    package var record: Record {
        var record = sessionRecord(type: Self.recordType, id: screenID.uuidString)

        record["category"] = name
        record["previous"] = previous
        record["end_date"] = endDate
        record["uuid"] = screenID.uuidString
        record["app_version"] = session?.appVersion

        return record
    }
}
