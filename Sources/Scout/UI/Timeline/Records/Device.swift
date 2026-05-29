//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

struct Device: Identifiable {
    let date: Date?
    let id: CKRecord.ID
    let deviceID: UUID?
}

extension Device: RecordDecodable {
    static let desiredKeys = [
        "date",
        "device_id",
    ]

    init(record: CKRecord) throws {
        date = record["date"]
        id = record.recordID
        deviceID = record["device_id"].flatMap(UUID.init)
    }
}

extension Device {
    static func sample(at date: Date) -> Device {
        Device(
            date: date,
            id: CKRecord.ID(recordName: UUID().uuidString),
            deviceID: nil
        )
    }
}
