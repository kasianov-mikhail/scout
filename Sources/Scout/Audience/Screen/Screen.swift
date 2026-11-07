//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package struct Screen: Identifiable {
    package let name: String
    package let previous: String?
    package let startDate: Date?
    package let endDate: Date?
    package let id: String
    package let sessionID: UUID?

    package init(name: String, previous: String?, startDate: Date?, endDate: Date?, id: String, sessionID: UUID?) {
        self.name = name
        self.previous = previous
        self.startDate = startDate
        self.endDate = endDate
        self.id = id
        self.sessionID = sessionID
    }
}

extension Screen: RecordDecodable {
    package static let recordType = ScreenEntry.recordType

    package static let desiredKeys = [
        "category",
        "previous",
        "date",
        "end_date",
        "session_id",
    ]

    package init(record: Record) throws {
        name = record["category"] ?? ""
        previous = record["previous"]
        startDate = record["date"]
        endDate = record["end_date"]
        id = record.recordID
        sessionID = record["session_id"].flatMap(UUID.init)
    }
}

extension Screen: RecordEncodable {
    package var record: Record {
        var record = Record(recordType: Self.recordType, recordID: id)

        record["category"] = name
        record["previous"] = previous
        record["date"] = startDate
        record["end_date"] = endDate
        record["uuid"] = id
        record["session_id"] = sessionID?.uuidString

        return record
    }
}
