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

    func fetch(in database: AppDatabase) async {
        do {
            let query = RecordQuery(
                recordType: CrashObject.recordType,
                filters: Calendar.utc.defaultRange.dateFilters,
                sort: [RecordSort(field: "date", ascending: false)]
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

    func fetchMore(cursor: RecordCursor, in database: AppDatabase) async {
        do {
            let results = try await database.readMore(
                from: cursor,
                fields: nil
            )

            self.cursor = results.cursor
            self.crashes?.append(contentsOf: try results.records.map(Crash.init))
        } catch {
            // Keep existing data on pagination failure
        }
    }
}
