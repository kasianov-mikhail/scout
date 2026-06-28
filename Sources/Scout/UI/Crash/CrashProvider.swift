//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

@MainActor
class CrashProvider: ObservableObject {
    @Published var crashes: [Crash]?
    @Published var cursor: RecordCursor?

    var groups: [CrashGroup]? {
        crashes.map(CrashGroup.groups(from:))
    }

    func fetch(in database: DatabaseReader) async {
        do {
            let query = RecordQuery(
                recordType: Crash.self,
                filters: Calendar.utc.defaultRange.dateFilters,
                sort: [RecordQuery.Sort(field: "date", ascending: false)]
            )

            let results = try await database.read(
                matching: query,
                fields: Crash.desiredKeys
            )

            self.cursor = results.cursor
            self.crashes = try results.records.map(Crash.init)
        } catch {
            self.crashes = []
        }
    }

    func fetchMore(cursor: RecordCursor, in database: DatabaseReader) async {
        do {
            let results = try await database.readMore(
                from: cursor,
                fields: nil
            )

            self.cursor = results.cursor
            self.crashes?.append(contentsOf: try results.records.map(Crash.init))
        } catch {
        }
    }
}
