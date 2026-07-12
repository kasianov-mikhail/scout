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

    private var query: RecordQuery {
        RecordQuery(
            recordType: Element.self,
            filters: Calendar.utc.defaultRange.dateFilters + [
                RecordQuery.Filter(field: "app_version", op: .equals, value: .string(version))
            ]
        )
    }

    @discardableResult
    func fetchLatest(in database: DatabaseReader) async -> Bool {
        do {
            records = try await database.readAll(
                matching: query,
                fields: Element.desiredKeys
            )
            return true
        } catch is CancellationError {
            return true
        } catch {
            if records == nil {
                message = Message(error.localizedDescription, level: .error)
            }
            return false
        }
    }
}
