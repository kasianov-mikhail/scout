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

    // Bumped by `clear()` so a response that was in flight when the feed was cleared
    // (a pull racing a filter change) cannot merge stale records or its cursor back in.
    private var generation = 0

    init(_ records: [Element]? = nil) {
        self.records = records
    }

    @discardableResult
    func fetchLatest(matching query: RecordQuery, in database: DatabaseReader) async -> Bool {
        let generation = generation
        do {
            let results = try await database.read(matching: query, fields: Element.desiredKeys)
            guard generation == self.generation else {
                return true
            }
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
        let generation = generation
        do {
            let results: [Element] = try await database.readAll(matching: query, fields: Element.desiredKeys)
            guard generation == self.generation else {
                return true
            }
            records = results
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
        let generation = generation
        do {
            let results = try await database.read(matching: query, fields: Element.desiredKeys)
            guard generation == self.generation else {
                return
            }
            cursor = results.cursor
            records = try results.records.map(Element.init)
        } catch is CancellationError {
            // A cancelled task (e.g. the view was recreated) leaves the feed untouched so it retries.
        } catch {
            message = Message(error.localizedDescription, level: .error)
        }
    }

    func fetchMore(cursor: RecordCursor, in database: DatabaseReader) async {
        let generation = generation
        do {
            let results = try await database.readMore(from: cursor, fields: nil)
            guard generation == self.generation else {
                return
            }
            self.cursor = results.cursor
            records = dedup(new: records ?? [], old: try results.records.map(Element.init))
        } catch is CancellationError {
        } catch {
            message = Message(error.localizedDescription, level: .error)
        }
    }

    func clear() {
        generation += 1
        records = nil
        cursor = nil
    }
}
