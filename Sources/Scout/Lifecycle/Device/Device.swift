//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package struct Device {
    package let date: Date?
    package let id: String
    package let deviceID: UUID?

    package init(date: Date?, id: String, deviceID: UUID?) {
        self.date = date
        self.id = id
        self.deviceID = deviceID
    }
}

extension Device: RecordDecodable {
    package static let recordType = DeviceEntry.recordType

    package static let desiredKeys = [
        "date",
        "device_id",
    ]

    package init(record: Record) throws {
        date = record["date"]
        id = record.recordID
        deviceID = record["device_id"].flatMap(UUID.init)
    }
}

extension Device: RecordEncodable {
    package var record: Record {
        var record = Record(recordType: Self.recordType, recordID: id)
        record["date"] = date
        record["device_id"] = deviceID?.uuidString
        return record
    }
}
