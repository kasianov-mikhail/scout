//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct Crash: Identifiable, Hashable {
    let name: String
    let fingerprint: String?
    let reason: String?
    let stackTrace: [String]
    let date: Date?
    let id: String
    let installID: UUID?
    let launchID: UUID?
    let sessionID: UUID?
}

struct CrashGroup: Identifiable, Hashable {
    let fingerprint: String
    let crashes: [Crash]
}

extension Crash: RecordDecodable {
    static let recordType = CrashObject.recordType
    static let sampleRecords: [Record] = []

    static let desiredKeys = [
        "name",
        "fingerprint",
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
        fingerprint = record["fingerprint"] ?? CrashFingerprint(name: name, reason: reason, stackTrace: stackTrace).value
    }
}

extension CrashGroup {
    var id: String { fingerprint }

    var name: String {
        representative.name
    }

    var reason: String? {
        representative.reason
    }

    var stackTrace: [String] {
        representative.stackTrace
    }

    var count: Int {
        crashes.count
    }

    var affectedSessions: Int {
        Set(crashes.compactMap(\.sessionID)).count
    }

    var firstDate: Date? {
        crashes.compactMap(\.date).min()
    }

    var lastDate: Date? {
        crashes.compactMap(\.date).max()
    }

    var representative: Crash {
        crashes.first ?? .sample(name: "Unknown crash", fingerprint: fingerprint)
    }

    static func groups(from crashes: [Crash]) -> [CrashGroup] {
        Dictionary(grouping: crashes, by: \.groupingFingerprint)
            .map { fingerprint, crashes in
                CrashGroup(
                    fingerprint: fingerprint,
                    crashes: crashes.sorted(by: Self.recentFirst)
                )
            }
            .sorted(by: Self.recentFirst)
    }

    private static func recentFirst(_ lhs: CrashGroup, _ rhs: CrashGroup) -> Bool {
        switch (lhs.lastDate, rhs.lastDate) {
        case let (lhs?, rhs?):
            if lhs != rhs {
                return lhs > rhs
            }
        case (_?, nil):
            return true
        case (nil, _?):
            return false
        case (nil, nil):
            break
        }

        if lhs.count != rhs.count {
            return lhs.count > rhs.count
        }

        return lhs.name < rhs.name
    }

    private static func recentFirst(_ lhs: Crash, _ rhs: Crash) -> Bool {
        switch (lhs.date, rhs.date) {
        case let (lhs?, rhs?):
            if lhs != rhs {
                return lhs > rhs
            }
        case (_?, nil):
            return true
        case (nil, _?):
            return false
        case (nil, nil):
            break
        }

        return lhs.id < rhs.id
    }
}

extension Crash {
    var groupingFingerprint: String {
        fingerprint ?? CrashFingerprint(name: name, reason: reason, stackTrace: stackTrace).value
    }
}

extension Crash {
    static var sample: Crash {
        Self.sample("NSRangeException", at: Date())
    }

    static func sample(_ name: String, at date: Date = Date(), sessionID: UUID? = nil) -> Crash {
        sample(name: name, fingerprint: nil, reason: nil, stackTrace: [], date: date, sessionID: sessionID)
    }

    static func sample(
        name: String,
        fingerprint: String? = nil,
        reason: String? = nil,
        stackTrace: [String] = [],
        date: Date? = Date(),
        sessionID: UUID? = nil
    ) -> Crash {
        Crash(
            name: name,
            fingerprint: fingerprint,
            reason: reason,
            stackTrace: stackTrace,
            date: date,
            id: UUID().uuidString,
            installID: nil,
            launchID: nil,
            sessionID: sessionID
        )
    }
}
