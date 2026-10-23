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

    // Set when a load fails while the feed is still empty, so the owning view can
    // render a full error state instead of an indefinite loading indicator.
    @Published private(set) var error: Error?

    private var generation = 0

    init(_ records: [Element]? = nil) {
        self.records = records
    }

    @discardableResult
    func fetchLatest(matching query: RecordQuery, in database: RecordReader) async -> Bool {
        if ProcessInfo.processInfo.isPreview {
            return true
        }

        let generation = generation
        do {
            let results = try await database.read(matching: query, fields: Element.desiredKeys)

            guard generation == self.generation else {
                return true
            }

            let latest = try results.records.map(Element.init)
            let loaded = Set(records?.map(\.id) ?? [])

            if results.cursor != nil, loaded.isDisjoint(with: latest.map(\.id)) {
                replace(records: latest, cursor: results.cursor)
            } else {
                if cursor == nil {
                    cursor = results.cursor
                }
                records = dedup(new: latest, old: records ?? [])
            }

            error = nil
            return true
        } catch is CancellationError {
            return true
        } catch {
            if records == nil {
                self.error = error
                message = Message(error.localizedDescription, level: .error)
            }
            return false
        }
    }

    func fetchAgain(matching query: RecordQuery, in database: RecordReader) async {
        if ProcessInfo.processInfo.isPreview {
            return
        }

        generation += 1
        let generation = generation

        do {
            let results = try await database.read(matching: query, fields: Element.desiredKeys)
            guard generation == self.generation else {
                return
            }
            try replace(records: results.records.map(Element.init), cursor: results.cursor)
            error = nil
        } catch is CancellationError {
            // A cancelled task (e.g. the view was recreated) leaves the feed untouched so it retries.
        } catch {
            if records == nil {
                self.error = error
            }
            message = Message(error.localizedDescription, level: .error)
        }
    }

    @discardableResult
    func fetchMore(cursor: RecordCursor, in database: RecordReader) async -> Bool {
        if ProcessInfo.processInfo.isPreview {
            return true
        }

        let generation = generation

        do {
            let results = try await cursor.next(nil)
            guard generation == self.generation else {
                return true
            }
            self.cursor = results.cursor
            records = dedup(new: records ?? [], old: try results.records.map(Element.init))
            return true
        } catch is CancellationError {
            return true
        } catch {
            message = Message(error.localizedDescription, level: .error)
            return false
        }
    }

    func clear() {
        replace(records: nil, cursor: nil)
        error = nil
    }

    private func replace(records: [Element]?, cursor: RecordCursor?) {
        generation += 1
        self.records = records
        self.cursor = cursor
    }
}
