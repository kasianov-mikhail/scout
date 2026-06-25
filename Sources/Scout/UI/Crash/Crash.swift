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
    let id: String
    let installID: UUID?
    let launchID: UUID?
    let sessionID: UUID?
}

extension Crash: RecordDecodable {
    static let recordType = CrashObject.recordType
    static let sampleRecords: [Record] = []

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

extension Crash {
    init(record: Record) throws {
        name = record["name"] ?? ""
        reason = record["reason"]
        date = record["date"]
        id = record.recordID
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
    static var sample: Crash {
        Self.sample("NSRangeException", at: Date())
    }

    static func sample(_ name: String, at date: Date, sessionID: UUID? = nil) -> Crash {
        Crash(
            name: name,
            reason: nil,
            stackTrace: [],
            date: date,
            id: UUID().uuidString,
            installID: nil,
            launchID: nil,
            sessionID: sessionID
        )
    }
}
