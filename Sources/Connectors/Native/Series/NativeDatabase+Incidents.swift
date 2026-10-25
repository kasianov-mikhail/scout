//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import ScoutDB

extension NativeDatabase: IncidentReader {
    func incidentIndex(recordType: String, in range: Range<Date>) async throws -> IncidentIndex? {
        let points = try await resolve()
            .query(recordType)
            .series(metric: .sum, group: CatalogEntry.incidentKey, in: range)

        let unkeyed = points.filter { IncidentKey(key: $0.group) == nil }.map(\.date)

        guard let first = unkeyed.min(), let last = unkeyed.max() else {
            return IncidentIndex(tallies: points.tallies, unkeyed: nil)
        }
        let end = last.addingTimeInterval(.hour)

        return IncidentIndex(
            tallies: points.filter { $0.date >= end }.tallies,
            unkeyed: first..<end
        )
    }
}

extension [SeriesPoint] {
    fileprivate var tallies: [IncidentTally] {
        Dictionary(grouping: self) { IncidentKey(key: $0.group) }.compactMap { key, points -> IncidentTally? in
            guard let key, let first = points.map(\.date).min() else {
                return nil
            }
            return IncidentTally(
                fingerprint: key.fingerprint,
                name: key.name,
                count: Int(points.reduce(0) { $0 + $1.value }),
                firstHour: first
            )
        }
    }
}
