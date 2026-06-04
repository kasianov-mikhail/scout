//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

struct Launch: Identifiable, Hashable {
    let startDate: Date?
    let endDate: Date?
    let id: CKRecord.ID
    let launchID: UUID?
    let installID: UUID?
}

extension Launch: RecordDecodable {
    static let desiredKeys = [
        "start_date",
        "end_date",
        "launch_id",
        "install_id",
    ]

    init(record: CKRecord) throws {
        startDate = record["start_date"]
        endDate = record["end_date"]
        id = record.recordID
        launchID = record["launch_id"].flatMap(UUID.init)
        installID = record["install_id"].flatMap(UUID.init)
    }
}
