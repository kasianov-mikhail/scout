//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension IncidentGroup {
    static func groups(from records: [Element], keys: [Element.ID: String] = [:], tallies: [String: IncidentTally] = [:], hasMore: Bool = false) -> [IncidentGroup] {
        let symbolicated = Set(keys.values)
        let grouped = Dictionary(grouping: records) { keys[$0.id] ?? $0.fingerprint }

        var owners: [String: Set<String>] = [:]
        for (key, records) in grouped {
            for record in records {
                owners[record.fingerprint, default: []].insert(key)
            }
        }
        let owned = tallies.filter { owners[$0.key]?.count == 1 }

        return
            grouped
            .map { key, records in
                IncidentGroup(
                    id: key,
                    records: records.sorted(),
                    symbol: symbolicated.contains(key) ? key.symbolName : nil,
                    tallies: owned,
                    hasMore: hasMore
                )
            }
            .sorted()
    }
}

extension String {
    fileprivate var symbolName: String? {
        split(separator: "|", maxSplits: 1).last.map(String.init)
    }
}
