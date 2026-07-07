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

    static var samples: [Device] {
        [
            .sample(minutesAgo: 0),
            .sample(minutesAgo: 4320),
            .sample(minutesAgo: 20160),
        ]
    }

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

extension Device {
    static func sample(minutesAgo: Double = 0, deviceID: UUID = UUID()) -> Device {
        Device(
            date: Date(timeIntervalSinceNow: -minutesAgo * 60),
            id: deviceID.uuidString,
            deviceID: deviceID
        )
    }
}
