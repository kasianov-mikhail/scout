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
    @Published var result: ProviderResult<[IncidentGroup<Element>]>?

    func fetch(in database: DatabaseReader) async throws -> [IncidentGroup<Element>] {
        let chunk = try await database.read(matching: query, fields: Element.desiredKeys)
        return IncidentGroup.groups(from: try chunk.records.map(Element.init))
    }

    private var query: RecordQuery {
        RecordQuery(
            recordType: Element.self,
            filters: Calendar.utc.defaultRange.dateFilters,
            sort: [RecordQuery.Sort(field: "date", ascending: false)]
        )
    }
}
