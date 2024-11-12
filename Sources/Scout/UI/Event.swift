//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import Logging
import SwiftUI

/// A structure representing an event.
struct Event: Identifiable {

    /// The name of the event.
    let name: String

    /// The logging level of the event, if applicable.
    let level: Logger.Level?

    /// The date when the event occurred, if available.
    let date: Date?

    /// The number of parameters associated with the event, if any.
    let paramCount: Int?

    /// A unique identifier for the event, if available.
    let uuid: UUID?

    /// The CloudKit record ID for the event.
    let id: CKRecord.ID

    /// The unique identifier for the user associated with the event, if any.
    let userID: UUID?

    /// The unique identifier for the session associated with the event, if any.
    let sessionID: UUID?
}

extension Event {

    /// The desired keys to fetch from CloudKit when fetching events.
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

    /// Initializes a new instance of `EventProvider` with the given results tuple.
    init(results: (CKRecord.ID, Result<CKRecord, Error>)) throws {
        try self.init(record: results.1.get())
    }

    /// Initializes a new instance of the class with the provided CKRecord.
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

// MARK: - EventLevel

/// This can be used to categorize and filter log messages based on their severity or importance.
typealias EventLevel = Logger.Level

extension EventLevel {

    /// A computed property that returns a string description for each case of the `EventLevel` enum.
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

    /// The color associated with the event level.
    /// This property returns an optional `Color` value that represents the color
    /// corresponding to the event level.
    ///
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

// MARK: - EventQuery

/// A structure representing a filter for events.
/// This can be used to filter events based on various criteria.
///
/// The `EventQuery` structure allows you to specify different criteria to filter events,
/// such as event levels, text, name, user ID, and session ID. It provides a method to
/// generate an `NSPredicate` object based on the specified criteria, which can be used
/// to filter events in a database or collection.
///
struct EventQuery {
    var levels = Set(EventLevel.allCases)
    var text = ""
    var name = ""
    var userID: UUID?
    var sessionID: UUID?

    /// Generates an `NSPredicate` object based on the current filter criteria.
    func buildPredicate() -> NSPredicate {
        var predicates: [NSPredicate] = []

        if levels != Set(EventLevel.allCases) {
            predicates.append(.init(format: "level IN %@", levels.map(\.rawValue)))
        }
        if !text.isEmpty {
            predicates.append(.init(format: "name BEGINSWITH %@", text.lowercased()))
        }
        if !name.isEmpty {
            predicates.append(.init(format: "name == %@", name))
        }
        if let userID = userID?.uuidString {
            predicates.append(.init(format: "user_id == %@", userID))
        }
        if let sessionID = sessionID?.uuidString {
            predicates.append(.init(format: "session_id == %@", sessionID))
        }

        return NSCompoundPredicate(type: .and, subpredicates: predicates)
    }
}

// MARK: - EventQuery

// TODO: Remove. Use the bool property directly.
struct EventHistory: EnvironmentKey {
    static let defaultValue = true
}

extension EnvironmentValues {
    var eventHistory: Bool {
        get { self[EventHistory.self] }
        set { self[EventHistory.self] = newValue }
    }
}

// MARK: -

extension EventQuery: CustomStringConvertible {
    var description: String {
        var components: [String] = []

        if levels != Set(EventLevel.allCases) {
            components.append("levels: \(levels.map(\.description).joined(separator: ", "))")
        }
        if !text.isEmpty {
            components.append("text: \(text)")
        }
        if !name.isEmpty {
            components.append("name: \(name)")
        }
        if let userID {
            components.append("userID: \(userID)")
        }
        if let sessionID {
            components.append("sessionID: \(sessionID)")
        }

        return components.joined(separator: ", \n")
    }
}
