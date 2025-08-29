//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct HistoryFilter {
    let name: String
    let userID: UUID
    let sessionID: UUID
    var category: Category
    var option = Option.event
}

extension HistoryFilter {
    init?(event: Event, category: Category) {
        guard let userID = event.userID, let sessionID = event.sessionID else {
            return nil
        }

        self.name = event.name
        self.userID = userID
        self.sessionID = sessionID
        self.category = category
    }
}

extension HistoryFilter {
    func query() -> EventQuery {
        let name =
            switch option {
            case .event:
                name
            case .all:
                ""
            }

        let eventFilter =
            switch category {
            case .user:
                EventQuery(name: name, userID: userID)
            case .session:
                EventQuery(name: name, sessionID: sessionID)
            }

        return eventFilter
    }
}

extension HistoryFilter {
    enum Category: CaseIterable, Identifiable {
        case user, session

        var id: Self { self }

        var title: String {
            switch self {
            case .user:
                return "User"
            case .session:
                return "Session"
            }
        }
    }

    enum Option: Identifiable {
        case event, all

        var id: Self { self }

        var title: String {
            switch self {
            case .event:
                return "Event"
            case .all:
                return "All"
            }
        }

        /// Toggles the current option between `event` and `all`.
        mutating func toggle() {
            switch self {
            case .event:
                self = .all
            case .all:
                self = .event
            }
        }
    }
}

extension HistoryFilter: CustomStringConvertible {
    var description: String {
        "HistoryFilter(name: \(name), userID: \(userID), sessionID: \(sessionID), category: \(category))"
    }
}
