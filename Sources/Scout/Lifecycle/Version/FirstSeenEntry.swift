//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(FirstSeenEntry)
package final class FirstSeenEntry: SyncableEntry, HasInstall {
    package static let recordType = "FirstSeen"

    @NSManaged var appVersion: String?
    @NSManaged var name: String?
    @NSManaged var install: InstallEntry?

    override var isPurgeable: Bool {
        false
    }
}

extension FirstSeenEntry: RecordEncodable {
    package var record: Record {
        let recordName = "\(installID?.uuidString ?? "")-\(name ?? "")-\(appVersion ?? "")"
        var record = Record(recordType: Self.recordType, recordID: recordName)

        record["date"] = date
        record["name"] = name
        record["app_version"] = appVersion
        record["install_id"] = installID?.uuidString
        record["device_id"] = deviceID?.uuidString

        record.setValues(metadata)

        return record
    }
}
