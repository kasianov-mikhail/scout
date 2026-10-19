//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

@MainActor
final class IncidentGroupsProvider<Element: RecordDecodable & Incident>: ObservableObject, RecordProvider {
    @Published var result: ProviderResult<[IncidentGroup<Element>]>?

    func fetch(in database: RecordReader) async throws -> [IncidentGroup<Element>] {
        let records: [Element] = try await database.readAll(
            matching: Element.query(),
            fields: Element.desiredKeys
        )
        return IncidentGroup.groups(from: records)
    }
}
