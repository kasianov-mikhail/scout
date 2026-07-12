//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

@MainActor
class VersionIncidentProvider<Element: RecordDecodable & Incident>: ObservableObject {
    @Published var records: [Element]?
    @Published var message: Message?

    let version: String

    init(version: String, records: [Element]? = nil) {
        self.version = version
        self.records = records
    }

    func fetchIfNeeded(in database: DatabaseReader) async {
        if records == nil {
            await fetch(in: database)
        }
    }

    func fetch(in database: DatabaseReader) async {
        do {
            let query = RecordQuery(
                recordType: Element.self,
                filters: Calendar.utc.defaultRange.dateFilters + [
                    RecordQuery.Filter(field: "app_version", op: .equals, value: .string(version))
                ]
            )

            records = try await database.readAll(
                matching: query,
                fields: Element.desiredKeys
            )
        } catch {
            message = Message(error.localizedDescription, level: .error)
        }
    }
}
