//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package struct Version {
    package static let installMarker = "VersionInstall"
    package static let crashMarker = "VersionCrash"

    package let appVersion: String?
    let buildNumber: String?
    package let launchID: UUID?
    package let installID: UUID?
    package let date: Date?
    let id: String

    package init(appVersion: String?, buildNumber: String?, launchID: UUID?, installID: UUID? = nil, date: Date?, id: String) {
        self.appVersion = appVersion
        self.buildNumber = buildNumber
        self.launchID = launchID
        self.installID = installID
        self.date = date
        self.id = id
    }
}

extension Version: RecordDecodable {
    package static let recordType = "Version"

    package static let desiredKeys = [
        "app_version",
        "build_number",
        "launch_id",
        "install_id",
        "date",
    ]

    package init(record: Record) throws {
        appVersion = record["app_version"]
        buildNumber = record["build_number"]
        launchID = record["launch_id"].flatMap(UUID.init)
        installID = record["install_id"].flatMap(UUID.init)
        date = record["date"]
        id = record.recordID
    }
}

extension Version: RecordEncodable {
    package var record: Record {
        var record = Record(recordType: Self.recordType, recordID: id)
        record["app_version"] = appVersion
        record["build_number"] = buildNumber
        record["launch_id"] = launchID?.uuidString
        record["install_id"] = installID?.uuidString
        record["date"] = date
        return record
    }
}
