//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

enum IncidentSearchEntry<Element: Incident>: Identifiable {
    case group(IncidentGroup<Element>)
    case tally(IncidentTally)

    var id: String {
        switch self {
        case .group(let group):
            group.id
        case .tally(let tally):
            tally.fingerprint
        }
    }

    var name: String {
        switch self {
        case .group(let group):
            group.name
        case .tally(let tally):
            tally.name
        }
    }
}

extension IncidentSearchEntry {
    static func entries(tallies: [IncidentTally], unkeyed groups: [IncidentGroup<Element>]) -> [IncidentSearchEntry] {
        let unkeyed = Dictionary(groups.map { ($0.id, $0) }) { first, _ in first }

        let tallied = tallies.map { tally in
            guard let group = unkeyed[tally.fingerprint] else {
                return IncidentSearchEntry.tally(tally)
            }
            return .tally(
                IncidentTally(
                    fingerprint: tally.fingerprint,
                    name: tally.name,
                    count: tally.count + group.count,
                    firstHour: min(tally.firstHour, group.firstDate ?? tally.firstHour)
                )
            )
        }
        let fingerprints = Set(tallies.map(\.fingerprint))

        return tallied + groups.filter { !fingerprints.contains($0.id) }.map(IncidentSearchEntry.group)
    }
}
