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
final class EventProvider: FeedProvider<Event>, Periodic {
    let filter: EventQuery

    init(filter: EventQuery = EventQuery()) {
        self.filter = filter
        super.init()
    }

    func fetch(for filter: EventQuery, in database: DatabaseReader) async {
        await fetchAgain(matching: query(for: filter), in: database)
    }

    @discardableResult
    func fetchLatest(for filter: EventQuery, in database: DatabaseReader) async -> Bool {
        await fetchLatest(matching: query(for: filter), in: database)
    }

    @discardableResult
    func fetchLatest(in database: DatabaseReader) async -> Bool {
        await fetchLatest(for: filter, in: database)
    }

    private func query(for filter: EventQuery) -> RecordQuery {
        RecordQuery(
            recordType: Event.self,
            filters: filter.buildFilters(),
            sort: [RecordQuery.Sort(field: "date", ascending: false)]
        )
    }
}
