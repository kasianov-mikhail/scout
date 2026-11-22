//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout

@MainActor
final class EventProvider: FeedProvider<Event>, Refreshable {
    let filter: EventQuery

    init(_ records: [Event]? = nil, filter: EventQuery = EventQuery()) {
        self.filter = filter
        super.init(records)
    }

    func fetch(for filter: EventQuery, in database: RecordReader) async {
        await fetchAgain(matching: filter.recordQuery, in: database)
    }

    @discardableResult
    func fetchLatest(for filter: EventQuery, in database: RecordReader) async -> Bool {
        await fetchLatest(matching: filter.criteria.recordQuery, in: database)
    }

    func fetchLatest(in database: DatabaseReader) async {
        await fetchLatest(for: filter, in: database)
    }

    func fetchAgain(in database: DatabaseReader) async {
        await fetch(for: filter, in: database)
    }
}
