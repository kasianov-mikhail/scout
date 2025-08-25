//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import Foundation
import SwiftUI

/// A class responsible for fetching and managing events from CloudKit.
@MainActor
class EventProvider: ObservableObject {

    /// The list of events fetched from CloudKit.
    @Published var events: [Event]?

    /// The cursor for fetching additional events.
    @Published var cursor: CKQueryOperation.Cursor?

    /// The error that occurred while fetching events.
    @Published var message: Message?

    /// Fetches events from CloudKit based on the provided filter.
    ///
    /// - Parameters:
    ///   - filter: The filter criteria for fetching events.
    ///   - container: The CloudKit container to fetch events from.
    ///
    func fetch(for filter: EventQuery, in database: DatabaseController) async {
        do {
            let query = CKQuery(recordType: "Event", predicate: filter.buildPredicate())
            query.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

            let results = try await database.records(
                matching: query,
                desiredKeys: Event.desiredKeys
            )

            self.cursor = results.queryCursor
            self.events = try results.matchResults.map(Event.init)
        } catch {
            self.message = Message(error.localizedDescription, level: .error)
        }
    }

    /// Fetches more events from CloudKit using the provided cursor.
    ///
    /// - Parameters:
    ///   - cursor: The cursor to continue fetching events from.
    ///   - container: The CloudKit container to fetch events from.
    ///
    func fetchMore(cursor: CKQueryOperation.Cursor, in database: DatabaseController) async {
        do {
            let results = try await database.records(
                continuingMatchFrom: cursor
            )

            self.cursor = results.queryCursor
            self.events?.append(contentsOf: try results.matchResults.map(Event.init))
        } catch {
            self.message = Message(error.localizedDescription, level: .error)
        }
    }
}
