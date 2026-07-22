//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Combine
import Foundation
import Scout

@MainActor
class FeedProvider<Element: RecordDecodable & Identifiable>: ObservableObject {
    @Published var records: [Element]?
    @Published var cursor: RecordCursor?
    @Published var message: Message?

    @discardableResult
    func fetchLatest(matching query: RecordQuery, in database: DatabaseReader) async -> Bool {
        do {
            let results = try await database.read(matching: query, fields: Element.desiredKeys)
            if cursor == nil {
                cursor = results.cursor
            }
            records = dedup(new: try results.records.map(Element.init), old: records ?? [])
            return true
        } catch is CancellationError {
            return true
        } catch {
            if records == nil {
                message = Message(error.localizedDescription, level: .error)
            }
            return false
        }
    }

    @discardableResult
    func fetchAll(matching query: RecordQuery, in database: DatabaseReader) async -> Bool {
        do {
            records = try await database.readAll(matching: query, fields: Element.desiredKeys)
            return true
        } catch is CancellationError {
            return true
        } catch {
            if records == nil {
                message = Message(error.localizedDescription, level: .error)
            }
            return false
        }
    }

    func fetchAgain(matching query: RecordQuery, in database: DatabaseReader) async {
        do {
            let results = try await database.read(matching: query, fields: Element.desiredKeys)
            cursor = results.cursor
            records = try results.records.map(Element.init)
        } catch {
            message = Message(error.localizedDescription, level: .error)
        }
    }

    func fetchMore(cursor: RecordCursor, in database: DatabaseReader) async {
        do {
            let results = try await database.readMore(from: cursor, fields: nil)
            self.cursor = results.cursor
            records = dedup(new: records ?? [], old: try results.records.map(Element.init))
        } catch {
            message = Message(error.localizedDescription, level: .error)
        }
    }

    func clear() {
        records = nil
        cursor = nil
    }
}
