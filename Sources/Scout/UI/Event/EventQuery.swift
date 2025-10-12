//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct EventQuery {
    var levels = Set(Event.Level.allCases)
    var text = ""
    var name = ""
    var userID: UUID?
    var sessionID: UUID?
    var dates: Range<Date>?

    func buildPredicate() -> NSPredicate {
        var predicates: [NSPredicate] = []

        if levels != Set(Event.Level.allCases) {
            predicates.append(.init(format: "level IN %@", levels.map(\.rawValue)))
        }
        if !text.isEmpty {
            predicates.append(.init(format: "name BEGINSWITH %@", text))
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
        if let dates {
            predicates.append(
                .init(
                    format: "date >= %@ AND date < %@",
                    dates.lowerBound as NSDate,
                    dates.upperBound as NSDate
                )
            )
        }

        return NSCompoundPredicate(type: .and, subpredicates: predicates)
    }
}

extension EventQuery: CustomStringConvertible {
    var description: String {
        var components: [String] = []

        if levels != Set(Event.Level.allCases) {
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
        if let dates {
            components.append("dates: \(dates.lowerBound) - \(dates.upperBound)")
        }

        return components.joined(separator: ", \n")
    }
}
