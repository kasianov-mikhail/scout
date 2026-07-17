//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package struct Version {
    package let appVersion: String?
    package let buildNumber: String?
    package let launchID: UUID?
    package let date: Date?
    package let id: String

    package init(appVersion: String?, buildNumber: String?, launchID: UUID?, date: Date?, id: String) {
        self.appVersion = appVersion
        self.buildNumber = buildNumber
        self.launchID = launchID
        self.date = date
        self.id = id
    }
}

extension Version: RecordDecodable {
    package static let recordType = VersionEntry.recordType

    package static let desiredKeys = [
        "app_version",
        "build_number",
        "launch_id",
        "date",
    ]

    package init(record: Record) throws {
        appVersion = record["app_version"]
        buildNumber = record["build_number"]
        launchID = record["launch_id"].flatMap(UUID.init)
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
        record["date"] = date
        return record
    }
}
