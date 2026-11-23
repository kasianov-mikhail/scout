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
final class EventUpdates: ObservableObject {
    @Published private(set) var counts: [EventLevel: Int] = [:]
    @Published private(set) var hasMore = false

    private var shown: Set<String> = []
    private var baseline: Date?
    private var newest: Date?
    private var levels: [String: EventLevel] = [:]
    private var generation = 0

    func observe(provider: EventProvider, filter: EventQuery, in database: DatabaseReader, changes: any EventUpdatesSource) async {
        let stream = await changes.changes()
        await provider.fetchLatest(for: filter, in: database)
        recordBaseline(provider.records)

        for await _ in stream {
            guard !Task.isCancelled else {
                return
            }
            if provider.records == nil {
                await provider.fetchLatest(for: filter, in: database)
                recordBaseline(provider.records)
            } else {
                await refresh(provider: provider, filter: filter, in: database)
            }
        }
    }

    @discardableResult
    func reload(provider: EventProvider, filter: EventQuery, in database: DatabaseReader) async -> Bool {
        clear()
        await provider.fetch(for: filter, in: database)
        recordBaseline(provider.records)
        return true
    }

    func clear() {
        generation += 1
        shown = []
        baseline = nil
        newest = nil
        levels = [:]
        hasMore = false
        counts = [:]
    }

    func recordBaseline(_ records: [Event]?) {
        generation += 1
        shown = Set(records?.map(\.id) ?? [])
        baseline = records?.first?.date ?? Date()
        newest = nil
        levels = [:]
        hasMore = false
        counts = [:]
    }

    func refresh(provider: EventProvider, filter: EventQuery, in database: DatabaseReader) async {
        guard let baseline else {
            return
        }
        if hasMore, levels.count >= defaultRecordPageSize {
            return
        }

        var query = provider.query(for: filter)
        query.filters.append(
            RecordQuery.Filter(field: "date", op: .greaterThanOrEquals, value: .date(max(baseline, newest ?? baseline)))
        )

        let generation = generation
        guard let chunk = try? await database.read(matching: query, fields: ["date", "level"], limit: defaultRecordPageSize) else {
            return
        }
        guard generation == self.generation else {
            return
        }

        var added = 0
        for record in chunk.records {
            guard let event = try? Event(record: record), !shown.contains(event.id), levels[event.id] == nil else {
                continue
            }
            guard levels.count < defaultRecordPageSize else {
                hasMore = true
                break
            }
            levels[event.id] = event.level ?? .info
            if let date = event.date {
                newest = max(newest ?? date, date)
            }
            added += 1
        }

        if added == chunk.records.count, chunk.cursor != nil {
            hasMore = true
        }

        counts = levels.values.reduce(into: [:]) { $0[$1, default: 0] += 1 }
    }
}
