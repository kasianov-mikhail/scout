//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct Install: Identifiable, Hashable {
    let date: Date?
    let id: RecordID
    let installID: UUID?
    let deviceID: UUID?
}

extension Install: RecordDecodable {
    static let desiredKeys = [
        "date",
        "install_id",
        "device_id",
    ]

    init(record: Record) throws {
        date = record["date"]
        id = record.id
        installID = record["install_id"].flatMap(UUID.init)
        deviceID = record["device_id"].flatMap(UUID.init)
    }
}
