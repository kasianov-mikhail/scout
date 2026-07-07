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

    static let desiredKeys = [
        "date",
        "install_id",
        "device_id",
    ]

    static var samples: [Install] {
        let deviceID = UUID()
        return [
            .sample(minutesAgo: 0, deviceID: deviceID),
            .sample(minutesAgo: 4320, deviceID: deviceID),
        ]
    }

    init(record: Record) throws {
        date = record["date"]
        id = record.recordID
        installID = record["install_id"].flatMap(UUID.init)
        deviceID = record["device_id"].flatMap(UUID.init)
    }
}

extension Install: RecordEncodable {
    var record: Record {
        var record = Record(recordType: Self.recordType, recordID: id)
        record["date"] = date
        record["install_id"] = installID?.uuidString
        record["device_id"] = deviceID?.uuidString
        return record
    }
}

extension Install {
    static func sample(minutesAgo: Double = 0, installID: UUID = UUID(), deviceID: UUID = UUID()) -> Install {
        Install(
            date: Date(timeIntervalSinceNow: -minutesAgo * 60),
            id: installID.uuidString,
            installID: installID,
            deviceID: deviceID
        )
    }
}
