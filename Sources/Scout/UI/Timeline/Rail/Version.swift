//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct Version: Identifiable, Hashable {
    let appVersion: String?
    let buildNumber: String?
    let launchID: UUID?
    let date: Date?
    let id: String
}

extension Version: RecordDecodable {
    static let recordType = VersionObject.recordType
    static let sampleRecords: [Record] = []

    static let desiredKeys = [
        "app_version",
        "build_number",
        "launch_id",
        "date",
    ]
}

extension Version {
    init(record: Record) throws {
        appVersion = record["app_version"]
        buildNumber = record["build_number"]
        launchID = record["launch_id"].flatMap(UUID.init)
        date = record["date"]
        id = record.recordID
    }
}
