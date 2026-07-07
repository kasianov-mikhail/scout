//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct Launch {
    let startDate: Date?
    let endDate: Date?
    let id: String
    let launchID: UUID?
    let installID: UUID?
}

extension Launch: RecordDecodable {
    static let recordType = LaunchObject.recordType

    static let desiredKeys = [
        "start_date",
        "end_date",
        "launch_id",
        "install_id",
    ]

    static var samples: [Launch] {
        let installID = UUID()
        return [
            .sample(minutesAgo: 0, installID: installID, ongoing: true),
            .sample(minutesAgo: 90, installID: installID),
        ]
    }

    init(record: Record) throws {
        startDate = record["start_date"]
        endDate = record["end_date"]
        id = record.recordID
        launchID = record["launch_id"].flatMap(UUID.init)
        installID = record["install_id"].flatMap(UUID.init)
    }
}

extension Launch: RecordEncodable {
    var record: Record {
        var record = Record(recordType: Self.recordType, recordID: id)
        record["start_date"] = startDate
        record["end_date"] = endDate
        record["launch_id"] = launchID?.uuidString
        record["install_id"] = installID?.uuidString
        return record
    }
}

extension Launch {
    static func sample(minutesAgo: Double = 0, launchID: UUID = UUID(), installID: UUID = UUID(), ongoing: Bool = false) -> Launch {
        let startDate = Date(timeIntervalSinceNow: -minutesAgo * 60)
        return Launch(
            startDate: startDate,
            endDate: ongoing ? nil : startDate.addingTimeInterval(180),
            id: launchID.uuidString,
            launchID: launchID,
            installID: installID
        )
    }
}
