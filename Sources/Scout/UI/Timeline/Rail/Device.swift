//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct Device {
    let date: Date?
    let id: String
    let deviceID: UUID?
}

extension Device: RecordDecodable {
    static let recordType = DeviceObject.recordType

    static let desiredKeys = [
        "date",
        "device_id",
    ]

    init(record: Record) throws {
        date = record["date"]
        id = record.recordID
        deviceID = record["device_id"].flatMap(UUID.init)
    }
}

extension Device: RecordEncodable {
    var record: Record {
        var record = Record(recordType: Self.recordType, recordID: id)
        record["date"] = date
        record["device_id"] = deviceID?.uuidString
        return record
    }
}
