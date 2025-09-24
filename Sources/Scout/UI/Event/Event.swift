//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import Logging
import SwiftUI

struct Event: Identifiable {
    let name: String
    let level: Logger.Level?
    let date: Date?
    let paramCount: Int?
    let uuid: UUID?
    let id: CKRecord.ID
    let userID: UUID?
    let sessionID: UUID?
}

extension Event {
    static let desiredKeys = [
        "name",
        "level",
        "date",
        "param_count",
        "uuid",
        "user_id",
        "session_id",
    ]
}

extension Event {
    init(results: (CKRecord.ID, Result<CKRecord, Error>)) throws {
        try self.init(record: results.1.get())
    }

    init(record: CKRecord) throws {
        name = record["name"] ?? ""
        level = record["level"].flatMap { EventLevel(rawValue: $0) }
        date = record["date"]
        paramCount = record["param_count"]
        uuid = record["uuid"].flatMap { UUID(uuidString: $0) }
        id = record.recordID
        userID = record["user_id"].flatMap { UUID(uuidString: $0) }
        sessionID = record["session_id"].flatMap { UUID(uuidString: $0) }
    }
}

typealias EventLevel = Logger.Level

extension EventLevel {
    var description: String {
        switch self {
        case .notice:
            "Notice"
        case .debug:
            "Debug"
        case .trace:
            "Trace"
        case .info:
            "Info"
        case .warning:
            "Warning"
        case .error:
            "Error"
        case .critical:
            "Critical"
        }
    }

    var color: Color? {
        switch self {
        case .notice, .debug, .trace, .info:
            return nil
        case .warning, .error:
            return .yellow
        case .critical:
            return .red
        }
    }
}
