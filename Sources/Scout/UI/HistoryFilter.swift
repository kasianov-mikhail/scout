//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// A structure representing a filter for event items.
/// This can be used to filter history records based on certain criteria.
///
struct HistoryFilter {

    /// The name of the event.
    let name: String

    /// The user ID.
    let userID: UUID

    /// The session ID.
    let sessionID: UUID

    /// The category to filter by.
    var category: Category

    /// The option to filter by.
    var option = Option.event
}

extension HistoryFilter {

    /// Initializes a new `HistoryFilter` instance with the given event and category.
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

// MARK: - Query Generation

extension HistoryFilter {

    /// Generates and returns an `EventQuery` object.
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

// MARK: - Models

extension HistoryFilter {

    /// An enumeration representing different categories in the history UI.
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

    /// An enumeration representing different options for history view.
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

// MARK: -

extension HistoryFilter: CustomStringConvertible {
    var description: String {
        "HistoryFilter(name: \(name), userID: \(userID), sessionID: \(sessionID), category: \(category))"
    }
}
