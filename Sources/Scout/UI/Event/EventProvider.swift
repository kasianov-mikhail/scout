//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import Foundation
import SwiftUI

@MainActor
class EventProvider: ObservableObject {
    @Published var events: [Event]?
    @Published var cursor: CKQueryOperation.Cursor?
    @Published var message: Message?

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
            self.message = error.toMessage()
        }
    }

    func fetchMore(cursor: CKQueryOperation.Cursor, in database: DatabaseController) async {
        do {
            let results = try await database.records(
                continuingMatchFrom: cursor
            )

            self.cursor = results.queryCursor
            self.events?.append(contentsOf: try results.matchResults.map(Event.init))
        } catch {
            self.message = error.toMessage()
        }
    }
}
