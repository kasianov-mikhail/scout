//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

struct SessionRail: Identifiable {
    let session: Session
    let events: [Event]
    let crashes: [Crash]

    var id: CKRecord.ID { session.id }
}

struct Session: Identifiable, Hashable {
    let startDate: Date?
    let endDate: Date?
    let id: CKRecord.ID
    let sessionID: UUID?
    let launchID: UUID?
    let installID: UUID?
}

extension Session: RecordDecodable {
    static let desiredKeys = [
        "start_date",
        "end_date",
        "session_id",
        "launch_id",
        "install_id",
    ]

    init(record: CKRecord) throws {
        startDate = record["start_date"]
        endDate = record["end_date"]
        id = record.recordID
        sessionID = record["session_id"].flatMap(UUID.init)
        launchID = record["launch_id"].flatMap(UUID.init)
        installID = record["install_id"].flatMap(UUID.init)
    }
}

extension Session {
    static func sample(at date: Date) -> Session {
        Session(
            startDate: date,
            endDate: nil,
            id: CKRecord.ID(recordName: UUID().uuidString),
            sessionID: nil,
            launchID: nil,
            installID: nil
        )
    }
}
