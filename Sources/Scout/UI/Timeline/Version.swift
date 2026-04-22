//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

struct Version: Identifiable {
    let date: Date?
    let appVersion: String?
    let buildNumber: String?
    let id: CKRecord.ID
    let launchID: UUID?
    let installID: UUID?
}

extension Version {
    static let desiredKeys = [
        "date",
        "app_version",
        "build_number",
        "launch_id",
        "install_id",
    ]
}

extension Version: RecordDecodable {
    init(record: CKRecord) throws {
        date = record["date"]
        appVersion = record["app_version"]
        buildNumber = record["build_number"]
        id = record.recordID
        launchID = record["launch_id"].flatMap(UUID.init)
        installID = record["install_id"].flatMap(UUID.init)
    }
}
