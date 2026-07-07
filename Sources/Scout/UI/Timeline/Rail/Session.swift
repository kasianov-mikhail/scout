//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct Session: Identifiable {
    let startDate: Date?
    let endDate: Date?
    let id: String
    let sessionID: UUID?
    let launchID: UUID?
    let installID: UUID?
}

extension Session: RecordDecodable {
    static let recordType = SessionObject.recordType

    static let desiredKeys = [
        "start_date",
        "end_date",
        "session_id",
        "launch_id",
        "install_id",
    ]

    static var samples: [Session] {
        let launchID = UUID()
        let installID = UUID()
        return [
            .sample(minutesAgo: 0, launchID: launchID, installID: installID, ongoing: true),
            .sample(minutesAgo: 45, launchID: launchID, installID: installID),
        ]
    }

    init(record: Record) throws {
        startDate = record["start_date"]
        endDate = record["end_date"]
        id = record.recordID
        sessionID = record["session_id"].flatMap(UUID.init)
        launchID = record["launch_id"].flatMap(UUID.init)
        installID = record["install_id"].flatMap(UUID.init)
    }
}

extension Session: RecordEncodable {
    var record: Record {
        var record = Record(recordType: Self.recordType, recordID: id)
        record["start_date"] = startDate
        record["end_date"] = endDate
        record["session_id"] = sessionID?.uuidString
        record["launch_id"] = launchID?.uuidString
        record["install_id"] = installID?.uuidString
        return record
    }
}

extension Session {
    static func sample(minutesAgo: Double = 0, sessionID: UUID = UUID(), launchID: UUID = UUID(), installID: UUID = UUID(), ongoing: Bool = false) -> Session {
        let startDate = Date(timeIntervalSinceNow: -minutesAgo * 60)
        return Session(
            startDate: startDate,
            endDate: ongoing ? nil : startDate.addingTimeInterval(120),
            id: sessionID.uuidString,
            sessionID: sessionID,
            launchID: launchID,
            installID: installID
        )
    }
}
