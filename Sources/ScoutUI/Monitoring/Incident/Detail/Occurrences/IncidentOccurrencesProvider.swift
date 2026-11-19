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
    let now = Date()
    let name: String
    let range: IncidentRange

    init(group: IncidentGroup<Element>, range: IncidentRange = .year) {
        self.loaded = group.records
        self.fingerprints = Set(group.records.map(\.fingerprint)).sorted()
        self.regroup = group.replacing
        self.name = group.name
        self.range = range
        super.init(group.isPartial || group.hasAllRecords ? group.records : nil)
    }

    init(tally: IncidentTally, range: IncidentRange = .year) {
        self.loaded = []
        self.fingerprints = [tally.fingerprint]
        self.regroup = { records in
            IncidentGroup(id: tally.fingerprint, records: records, symbol: nil, tallies: [tally.fingerprint: tally], hasMore: false)
        }
        self.name = tally.name
        self.range = range
        super.init(nil)
    }

    var currentRange: Range<Date> {
        range.range(now: now)
    }

    var previousRange: Range<Date> {
        range.previousRange(now: now)
    }

    var currentRecords: [Element] {
        filter(records ?? loaded, in: currentRange)
    }

    var previousRecords: [Element] {
        filter(records ?? loaded, in: previousRange)
    }

    var group: IncidentGroup<Element> {
        regroup(currentRecords)
    }

    func fetchIfNeeded(in database: RecordReader) async {
        guard records == nil else {
            return
        }

        let filter = RecordQuery.Filter(field: "fingerprint", op: .in, value: .strings(fingerprints))
        await fetchLatest(matching: Element.query(in: previousRange.lowerBound..<currentRange.upperBound, filters: [filter]), in: database)

        if records == nil, error != nil, !loaded.isEmpty {
            records = loaded
        }
    }
}

extension IncidentOccurrencesProvider {
    private func filter(_ records: [Element], in range: Range<Date>) -> [Element] {
        records.filter { record in
            record.date.map(range.contains) ?? false
        }
    }
}
