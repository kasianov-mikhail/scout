//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import SwiftUI

@MainActor
final class EventProvider: FeedProvider<Event>, Refreshable {
    var filter: EventQuery

    @Published private(set) var newCounts: [EventLevel: Int] = [:]

    private var baseline: (hour: Date, counts: [EventLevel: Int])?

    init(_ records: [Event]? = nil, filter: EventQuery = EventQuery()) {
        self.filter = filter
        super.init(records)
    }

    func fetch(for filter: EventQuery, in database: RecordReader) async {
        await fetchAgain(matching: query(for: filter), in: database)
    }

    @discardableResult
    func fetchLatest(for filter: EventQuery, in database: RecordReader) async -> Bool {
        await fetchLatest(matching: query(for: filter.criteria), in: database)
    }

    func fetchLatest(in database: DatabaseReader) async {
        await fetchLatest(for: filter, in: database)
        await takeBaseline(in: database)
    }

    func fetchAgain(in database: DatabaseReader) async {
        await fetch(for: filter, in: database)
        await takeBaseline(in: database)
    }

    func refresh(in database: DatabaseReader) async {
        await fetchAgain(in: database)
    }

    func fetchNewer(in database: DatabaseReader) async {
        await refreshCounts(in: database)
    }

    private func takeBaseline(in database: DatabaseReader) async {
        newCounts = [:]

        guard filter.criteria.filters.isEmpty else {
            baseline = nil
            return
        }

        let now = Date()
        let hour = now.startOfHour
        baseline = (hour, await levelCounts(from: hour, to: now, in: database))
    }

    private func refreshCounts(in database: DatabaseReader) async {
        guard let baseline else {
            return
        }

        let now = Date()

        guard now.timeIntervalSince(baseline.hour) < 86400 else {
            await takeBaseline(in: database)
            return
        }

        let current = await levelCounts(from: baseline.hour, to: now, in: database)
        newCounts = current.reduce(into: [:]) { counts, pair in
            let delta = pair.value - (baseline.counts[pair.key] ?? 0)
            guard delta > 0 else {
                return
            }
            counts[pair.key] = delta
        }
    }

    private func levelCounts(from: Date, to: Date, in database: DatabaseReader) async -> [EventLevel: Int] {
        let query = EventSeriesQuery(group: .level, bucket: .hour, range: from..<to)

        guard let series = try? await database.eventSeries(matching: query) else {
            return [:]
        }

        return series.reduce(into: [:]) { counts, series in
            guard let level = EventLevel(rawValue: series.name) else {
                return
            }
            counts[level, default: 0] += series.points.reduce(0) { $0 + Int($1.value) }
        }
    }

    private func query(for filter: EventQuery) -> RecordQuery {
        RecordQuery(
            recordType: Event.self,
            filters: filter.filters,
            sort: [RecordQuery.Sort(field: "date", ascending: false)]
        )
    }
}
