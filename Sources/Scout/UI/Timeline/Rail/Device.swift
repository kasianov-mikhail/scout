//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct Device: Identifiable {
    let date: Date?
    let id: RecordID
    let deviceID: UUID?
}

extension Device: RecordDecodable {
    static let desiredKeys = [
        "date",
        "device_id",
    ]

    init(record: Record) throws {
        date = record["date"]
        id = record.id
        deviceID = record["device_id"].flatMap(UUID.init)
    }
}
