//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package struct Launch {
    package let startDate: Date?
    package let endDate: Date?
    package let id: String
    package let launchID: UUID?
    package let installID: UUID?

    package init(startDate: Date?, endDate: Date?, id: String, launchID: UUID?, installID: UUID?) {
        self.startDate = startDate
        self.endDate = endDate
        self.id = id
        self.launchID = launchID
        self.installID = installID
    }
}

extension Launch: RecordDecodable {
    package static let recordType = LaunchEntry.recordType

    package static let desiredKeys = [
        "start_date",
        "end_date",
        "launch_id",
        "install_id",
    ]

    package init(record: Record) throws {
        startDate = record["start_date"]
        endDate = record["end_date"]
        id = record.recordID
        launchID = record["launch_id"].flatMap(UUID.init)
        installID = record["install_id"].flatMap(UUID.init)
    }
}

extension Launch: RecordEncodable {
    package var record: Record {
        var record = Record(recordType: Self.recordType, recordID: id)
        record["start_date"] = startDate
        record["end_date"] = endDate
        record["launch_id"] = launchID?.uuidString
        record["install_id"] = installID?.uuidString
        return record
    }
}
