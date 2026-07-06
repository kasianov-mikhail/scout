//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

@MainActor
class CrashProvider: ObservableObject {
    @Published var groups: [CrashGroup]?
    @Published var cursor: RecordCursor?
    @Published var message: Message?

    private var crashes: [Crash] = []

    func fetchIfNeeded(in database: DatabaseReader) async {
        guard groups == nil else { return }
        await fetch(in: database)
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
            self.groups = CrashGroup.groups(from: crashes)
        } catch {
            self.message = Message(error.localizedDescription, level: .error)
        }
    }

    func fetchMore(cursor: RecordCursor, in database: DatabaseReader) async {
        do {
            let results = try await database.readMore(
                from: cursor,
                fields: nil
            )

            self.cursor = results.cursor
            self.crashes.append(contentsOf: try results.records.map(Crash.init))
            self.groups = CrashGroup.groups(from: crashes)
        } catch {
            self.message = Message(error.localizedDescription, level: .error)
        }
    }
}
