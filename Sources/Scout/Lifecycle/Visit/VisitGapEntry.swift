//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import CoreData

@objc(VisitGapEntry)
package final class VisitGapEntry: LaunchScopeEntry {
    package static let recordType = "VisitGap"

    package static let cap = 30

    @NSManaged var gap: Int16
    @NSManaged var appVersion: String?
}

extension VisitGapEntry: RecordEncodable {
    package var record: Record {
        let recordName = "\(deviceID?.uuidString ?? "")-\(day?.millisecondsSince1970 ?? 0)"
        var record = Record(recordType: Self.recordType, recordID: recordName)

        record["date"] = date
        record["gap"] = String(gap)
        record["app_version"] = appVersion
        record["launch_id"] = launchID?.uuidString
        record["install_id"] = installID?.uuidString
        record["device_id"] = deviceID?.uuidString

        record.setValues(metadata)

        return record
    }
}
