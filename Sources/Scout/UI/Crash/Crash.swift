//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct Crash: Identifiable, Hashable {
    let name: String
    let reason: String?
    let stackTrace: [String]
    let date: Date?
    let id: RecordID
    let installID: UUID?
    let launchID: UUID?
    let sessionID: UUID?
}

extension Crash {
    static let desiredKeys = [
        "name",
        "reason",
        "stack_trace",
        "date",
        "uuid",
        "install_id",
        "launch_id",
        "session_id",
    ]
}

extension Crash: RecordDecodable {
    init(record: Record) throws {
        name = record["name"] ?? ""
        reason = record["reason"]
        date = record["date"]
        id = record.id
        installID = record["install_id"].flatMap(UUID.init)
        launchID = record["launch_id"].flatMap(UUID.init)
        sessionID = record["session_id"].flatMap(UUID.init)

        if let data: Data = record["stack_trace"], let decoded = try? JSONDecoder().decode([String].self, from: data) {
            stackTrace = decoded
        } else {
            stackTrace = []
        }
    }
}

extension Crash {
    static func sample(_ name: String, at date: Date, sessionID: UUID? = nil) -> Crash {
        Crash(
            name: name,
            reason: nil,
            stackTrace: [],
            date: date,
            id: RecordID(recordName: UUID().uuidString),
            installID: nil,
            launchID: nil,
            sessionID: sessionID
        )
    }
}
