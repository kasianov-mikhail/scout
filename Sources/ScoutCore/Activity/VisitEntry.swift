//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import CoreData

@objc(VisitEntry)
package final class VisitEntry: SyncableEntry, HasLaunch {
    package static let recordType = "Visit"

    @NSManaged var visitID: UUID
    @NSManaged var launch: LaunchEntry?
}

extension VisitEntry: RecordEncodable {
    package var record: Record {
        // The deterministic name makes a re-sent marker overwrite its twin,
        // so the store keeps one visit per device per day.
        let recordName = "\(deviceID?.uuidString ?? "")-\(day?.millisecondsSince1970 ?? 0)"
        var record = Record(recordType: Self.recordType, recordID: recordName)

        record["date"] = date
        record["launch_id"] = launchID?.uuidString
        record["install_id"] = installID?.uuidString
        record["device_id"] = deviceID?.uuidString

        record.setValues(metadata)

        return record
    }
}
