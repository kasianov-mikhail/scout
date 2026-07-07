//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct Version {
    let appVersion: String?
    let buildNumber: String?
    let launchID: UUID?
    let date: Date?
    let id: String
}

extension Version: RecordDecodable {
    static let recordType = VersionObject.recordType

    static let desiredKeys = [
        "app_version",
        "build_number",
        "launch_id",
        "date",
    ]

    static var samples: [Version] {
        [
            .sample(appVersion: "2.4.1", buildNumber: "214", minutesAgo: 0),
            .sample(appVersion: "2.4.0", buildNumber: "210", minutesAgo: 4320),
        ]
    }

    init(record: Record) throws {
        appVersion = record["app_version"]
        buildNumber = record["build_number"]
        launchID = record["launch_id"].flatMap(UUID.init)
        date = record["date"]
        id = record.recordID
    }
}

extension Version: RecordEncodable {
    var record: Record {
        var record = Record(recordType: Self.recordType, recordID: id)
        record["app_version"] = appVersion
        record["build_number"] = buildNumber
        record["launch_id"] = launchID?.uuidString
        record["date"] = date
        return record
    }
}

extension Version {
    static func sample(appVersion: String = "2.4.1", buildNumber: String = "214", minutesAgo: Double = 0, launchID: UUID = UUID()) -> Version {
        Version(
            appVersion: appVersion,
            buildNumber: buildNumber,
            launchID: launchID,
            date: Date(timeIntervalSinceNow: -minutesAgo * 60),
            id: UUID().uuidString
        )
    }
}
