//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct Install {
    let date: Date?
    let id: String
    let installID: UUID?
    let deviceID: UUID?
}

extension Install: RecordDecodable {
    static let recordType = InstallObject.recordType
    static let sampleRecords: [Record] = []

    static let desiredKeys = [
        "date",
        "install_id",
        "device_id",
    ]
}

extension Install {
    init(record: Record) throws {
        date = record["date"]
        id = record.recordID
        installID = record["install_id"].flatMap(UUID.init)
        deviceID = record["device_id"].flatMap(UUID.init)
    }
}
