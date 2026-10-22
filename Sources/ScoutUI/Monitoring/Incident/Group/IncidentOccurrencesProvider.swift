//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

@MainActor
final class IncidentOccurrencesProvider<Element: RecordDecodable & Incident>: FeedProvider<Element> {
    private let loaded: [Element]
    private let fingerprints: [String]
    private let regroup: ([Element]) -> IncidentGroup<Element>

    init(group: IncidentGroup<Element>) {
        loaded = group.records
        fingerprints = Set(group.records.map(\.fingerprint)).sorted()
        regroup = group.replacing
        super.init(group.isPartial || group.hasAllRecords ? group.records : nil)
    }

    init(tally: IncidentTally) {
        loaded = []
        fingerprints = [tally.fingerprint]
        regroup = { records in
            IncidentGroup(id: tally.fingerprint, records: records, symbol: nil, tallies: [tally.fingerprint: tally], hasMore: false)
        }
        super.init(nil)
    }

    // Holds at least one record once a tallied group's first page is in.
    var group: IncidentGroup<Element> {
        regroup(records ?? loaded)
    }

    func fetchIfNeeded(in database: RecordReader) async {
        guard records == nil else {
            return
        }

        let filter = RecordQuery.Filter(field: "fingerprint", op: .in, value: .strings(fingerprints))
        await fetchLatest(matching: Element.query(filters: [filter]), in: database)

        if records == nil, error != nil, !loaded.isEmpty {
            records = loaded
        }
    }
}
