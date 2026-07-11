//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(VersionEntry)
final class VersionEntry: SyncableEntry, HasLaunch {
    static let recordType = "Version"

    @NSManaged var appVersion: String?
    @NSManaged var buildNumber: String?
    @NSManaged var launch: LaunchEntry?
}

extension VersionEntry: RecordEncodable {
    var record: Record {
        let recordName = "\(installID?.uuidString ?? "")-\(appVersion ?? "")-\(buildNumber ?? "")"
        var record = Record(recordType: Self.recordType, recordID: recordName)

        record["date"] = date
        record["app_version"] = appVersion
        record["build_number"] = buildNumber
        record["launch_id"] = launchID?.uuidString
        record["install_id"] = installID?.uuidString
        record["device_id"] = deviceID?.uuidString

        record.setValues(metadata)

        return record
    }
}
