//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import SwiftUI

/// A provider that handles paginated CloudKit queries.
///
/// Subclasses supply their query and desired keys; this class manages
/// the cursor, appending pages, and error handling.
///
@MainActor
class PaginatingProvider<Item: RecordDecodable>: ObservableObject {
    @Published var items: [Item]?
    @Published var cursor: CKQueryOperation.Cursor?
    @Published var message: Message?

    func fetch(
        matching query: CKQuery, fields: [CKRecord.FieldKey]?, in database: AppDatabase
    ) async {
        do {
            let results = try await database.read(matching: query, fields: fields)
            self.cursor = results.cursor
            self.items = try results.records.map(Item.init)
        } catch {
            handleFetchError(error)
        }
    }

    func fetchMore(cursor: CKQueryOperation.Cursor, in database: AppDatabase) async {
        do {
            let results = try await database.readMore(from: cursor, fields: nil)
            self.cursor = results.cursor
            self.items?.append(contentsOf: try results.records.map(Item.init))
        } catch {
            handlePaginationError(error)
        }
    }

    /// Override to customize initial fetch error handling.
    ///
    func handleFetchError(_ error: Error) {
        self.message = Message(error.localizedDescription, level: .error)
    }

    /// Override to customize pagination error handling.
    ///
    func handlePaginationError(_ error: Error) {
        self.message = Message(error.localizedDescription, level: .error)
    }
}
