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

    func fetch(for filter: Event.Query, in database: AppDatabase) async {
        do {
            let query = CKQuery(recordType: "Event", predicate: filter.buildPredicate())
            query.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

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

    func fetchMore(cursor: CKQueryOperation.Cursor, in database: AppDatabase) async {
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
