//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import SwiftUI

@MainActor
class EventProvider: ObservableObject {
    @Published var events: [Event]?
    @Published var cursor: RecordCursor?
    @Published var message: Message?

    func fetchIfNeeded(for filter: Event.Query, in database: DatabaseReader) async {
        guard events == nil else { return }
        await fetch(for: filter, in: database)
    }

    func fetch(for filter: Event.Query, in database: DatabaseReader) async {
        do {
            let query = RecordQuery(
                recordType: Event.self,
                filters: filter.buildFilters(),
                sort: [RecordQuery.Sort(field: "date", ascending: false)]
            )

            let results = try await database.read(
                matching: query,
                fields: Event.desiredKeys
            )

            self.cursor = results.cursor
            self.events = try results.records.map(Event.init)
        } catch {
            self.message = Message(error.localizedDescription, level: .error)
        }
    }

    func fetchMore(cursor: RecordCursor, in database: DatabaseReader) async {
        do {
            let results = try await database.readMore(
                from: cursor,
                fields: nil
            )

            self.cursor = results.cursor
            self.events?.append(contentsOf: try results.records.map(Event.init))
        } catch {
            self.message = Message(error.localizedDescription, level: .error)
        }
    }
}
