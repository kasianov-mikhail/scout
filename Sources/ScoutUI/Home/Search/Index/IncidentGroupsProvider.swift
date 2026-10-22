//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

@MainActor
final class IncidentGroupsProvider<Element: RecordDecodable & Incident>: ObservableObject, Provider {
    @Published var result: ProviderResult<[IncidentSearchEntry<Element>]>?

    func fetch(in database: DatabaseReader) async throws -> [IncidentSearchEntry<Element>] {
        try await entries(in: Date().trailingYear, from: database).sorted { $0.name < $1.name }
    }

    private func entries(in range: Range<Date>, from database: DatabaseReader) async throws -> [IncidentSearchEntry<Element>] {
        guard let index = try await database.incidentIndex(recordType: Element.recordType, in: range) else {
            return try await groups(in: range, from: database).map(IncidentSearchEntry.group)
        }
        guard let unkeyed = index.unkeyed else {
            return index.tallies.map(IncidentSearchEntry.tally)
        }

        let groups = try await groups(in: range.lowerBound..<min(unkeyed.upperBound, range.upperBound), from: database)
        return IncidentSearchEntry.entries(tallies: index.tallies, unkeyed: groups)
    }

    private func groups(in range: Range<Date>, from database: RecordReader) async throws -> [IncidentGroup<Element>] {
        let records: [Element] = try await database.readAll(
            matching: Element.query(in: range),
            fields: Element.desiredKeys
        )
        return IncidentGroup.groups(from: records)
    }
}
