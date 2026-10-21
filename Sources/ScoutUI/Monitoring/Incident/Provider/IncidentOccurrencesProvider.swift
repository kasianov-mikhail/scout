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
    private let loaded: IncidentGroup<Element>
    private let fingerprints: [String]

    init(group: IncidentGroup<Element>) {
        loaded = group
        fingerprints = Set(group.records.map(\.fingerprint)).sorted()
        super.init(group.isPartial || group.hasAllRecords ? group.records : nil)
    }

    var group: IncidentGroup<Element> {
        loaded.replacing(records: records ?? loaded.records)
    }

    func fetchIfNeeded(in database: RecordReader) async {
        guard records == nil else {
            return
        }

        let filter = RecordQuery.Filter(field: "fingerprint", op: .in, value: .strings(fingerprints))
        await fetchLatest(matching: Element.query(filters: [filter]), in: database)

        if records == nil, error != nil {
            records = loaded.records
        }
    }
}
