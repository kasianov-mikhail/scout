//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package struct Install {
    package let date: Date?
    package let id: String
    package let installID: UUID?
    package let deviceID: UUID?

    package init(date: Date?, id: String, installID: UUID?, deviceID: UUID?) {
        self.date = date
        self.id = id
        self.installID = installID
        self.deviceID = deviceID
    }
}

extension Install: RecordDecodable {
    package static let recordType = InstallEntry.recordType

    package static let desiredKeys = [
        "date",
        "install_id",
        "device_id",
    ]

    package init(record: Record) throws {
        date = record["date"]
        id = record.recordID
        installID = record["install_id"].flatMap(UUID.init)
        deviceID = record["device_id"].flatMap(UUID.init)
    }
}

extension Install: RecordEncodable {
    package var record: Record {
        var record = Record(recordType: Self.recordType, recordID: id)
        record["date"] = date
        record["install_id"] = installID?.uuidString
        record["device_id"] = deviceID?.uuidString
        return record
    }
}
