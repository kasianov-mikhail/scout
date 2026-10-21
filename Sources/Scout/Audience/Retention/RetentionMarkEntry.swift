//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(RetentionMarkEntry)
package final class RetentionMarkEntry: SyncableEntry, HasInstall {
    package static let recordType = "RetentionMark"

    @NSManaged var name: String
    @NSManaged var install: InstallEntry?

    override var isPurgeable: Bool {
        false
    }
}

extension RetentionMarkEntry: RecordEncodable {
    package var record: Record {
        let recordName = "\(installID?.uuidString ?? "")-\(name)"
        var record = Record(recordType: Self.recordType, recordID: recordName)

        record["date"] = date
        record["name"] = name
        record["install_date"] = install?.date
        record["os_version"] = install?.osVersion
        record["install_id"] = installID?.uuidString
        record["device_id"] = deviceID?.uuidString
        record.setValues(metadata)

        return record
    }
}
