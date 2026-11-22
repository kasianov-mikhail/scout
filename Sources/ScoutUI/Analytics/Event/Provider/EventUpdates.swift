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
    @Published private var state = State.ready(nil)

    private(set) var newEvents: NewEvents? {
        get {
            switch state {
            case .ready(let newEvents), .showing(let newEvents):
                newEvents
            }
        }
        set {
            switch state {
            case .ready:
                state = .ready(newValue)
            case .showing:
                state = .showing(newValue)
            }
        }
    }

    func observe(for filter: EventQuery, updating provider: EventProvider, in database: RecordReader, changes: EventChanges) async {
        let updates = await changes()
        let query = filter.recordQuery
        await reconcile(matching: query, updating: provider, in: database)

        for await _ in updates {
            await countNewEvents(matching: query, updating: provider, in: database)
        }
    }

    private func reconcile(matching query: RecordQuery, updating provider: EventProvider, in database: RecordReader) async {
        await provider.readFirstPage(matching: query, in: database, reportsRefreshFailure: false) { page, next in
            guard let records = provider.records, !records.isEmpty else {
                provider.replace(records: page, cursor: next)
                return
            }

            let shown = Set(records.map(\.id))
            let oldestShown = provider.cursor == nil ? nil : records.last?.date
            let additions = page.filter { event in
                guard !shown.contains(event.id) else {
                    return false
                }
                return oldestShown.map { (event.date ?? .distantPast) >= $0 } ?? true
            }
            if additions.isEmpty {
                newEvents = nil
                if !page.elementsEqual(records.prefix(page.count)) || (next == nil && page.count < records.count) {
                    provider.replace(records: page, cursor: next)
                }
                return
            }

            var summary = NewEvents(query: query)
            summary.include(additions, mayHaveMore: next != nil && additions.count == page.count)
            newEvents = summary
        }
    }

    private func countNewEvents(matching query: RecordQuery, updating provider: EventProvider, in database: RecordReader) async {
        if let newEvents, newEvents.hasMore, newEvents.levelsByID.count == defaultRecordPageSize {
            return
        }
        guard let records = provider.records, let newestShown = records.first?.date else {
            await reconcile(matching: query, updating: provider, in: database)
            return
        }

        let since = max(newestShown, newEvents?.latestDate ?? newestShown)
        var recent = query
        recent.filters.append(.init(field: "date", op: .greaterThanOrEquals, value: .date(since)))

        let shown = Set(records.prefix { ($0.date ?? .distantPast) >= since }.map(\.id))
        // The record ID is included in the envelope when selecting fields.
        await provider.readFirstPage(matching: recent, in: database, fields: ["date", "level"], reportsRefreshFailure: false) { page, next in
            var summary = newEvents ?? NewEvents(query: query)
            summary.include(page.filter { !shown.contains($0.id) }, mayHaveMore: next != nil)
            if !summary.levelsByID.isEmpty {
                newEvents = summary
            }
        }
    }

    func showNewEvents(updating provider: EventProvider, in database: RecordReader) async -> Bool {
        guard case .ready(let newEvents?) = state else {
            return false
        }
        state = .showing(newEvents)
        defer { state = .ready(self.newEvents) }

        var applied = false
        await provider.readFirstPage(matching: newEvents.query, in: database) { page, cursor in
            provider.replace(records: page, cursor: cursor)
            self.newEvents = nil
            applied = true
        }
        return applied
    }

    func clear() {
        newEvents = nil
    }

    private enum State {
        case ready(NewEvents?)
        case showing(NewEvents?)
    }

    struct NewEvents {
        fileprivate let query: RecordQuery
        fileprivate private(set) var levelsByID: [String: EventLevel] = [:]
        fileprivate private(set) var latestDate: Date?
        private(set) var hasMore = false

        var counts: [EventLevel: Int] {
            levelsByID.values.reduce(into: [:]) { $0[$1, default: 0] += 1 }
        }

        fileprivate init(query: RecordQuery) {
            self.query = query
        }

        fileprivate mutating func include(_ events: [Event], mayHaveMore: Bool) {
            hasMore = hasMore || mayHaveMore
            for event in events {
                if levelsByID[event.id] == nil && levelsByID.count == defaultRecordPageSize {
                    hasMore = true
                    break
                }
                levelsByID[event.id] = event.level ?? .info
                if let date = event.date {
                    latestDate = max(latestDate ?? date, date)
                }
            }
        }
    }
}
