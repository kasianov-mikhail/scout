//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct Version {
    let appVersion: String?
    let buildNumber: String?
    let launchID: UUID?
    let date: Date?
    let id: String
}

extension Version: RecordDecodable {
    static let recordType = VersionEntry.recordType

    static let desiredKeys = [
        "app_version",
        "build_number",
        "launch_id",
        "date",
    ]

    init(record: Record) throws {
        appVersion = record["app_version"]
        buildNumber = record["build_number"]
        launchID = record["launch_id"].flatMap(UUID.init)
        date = record["date"]
        id = record.recordID
    }
}

extension Version: RecordEncodable {
    var record: Record {
        var record = Record(recordType: Self.recordType, recordID: id)
        record["app_version"] = appVersion
        record["build_number"] = buildNumber
        record["launch_id"] = launchID?.uuidString
        record["date"] = date
        return record
    }
}
