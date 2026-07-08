//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

@MainActor
class ReliabilityProvider<Element: RecordDecodable & ReliabilityRecord>: ObservableObject {
    @Published var groups: [ReliabilityGroup<Element>]?
    @Published var cursor: RecordCursor?
    @Published var message: Message?

    private var records: [Element] = []

    func fetchIfNeeded(in database: DatabaseReader) async {
        guard groups == nil else { return }
        await fetch(in: database)
    }

    func fetch(in database: DatabaseReader) async {
        do {
            let query = RecordQuery(
                recordType: Element.self,
                filters: Calendar.utc.defaultRange.dateFilters,
                sort: [RecordQuery.Sort(field: "date", ascending: false)]
            )

            let results = try await database.read(
                matching: query,
                fields: Element.desiredKeys
            )

            self.cursor = results.cursor
            self.records = try results.records.map(Element.init)
            self.groups = ReliabilityGroup.groups(from: records)
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
            self.records.append(contentsOf: try results.records.map(Element.init))
            self.groups = ReliabilityGroup.groups(from: records)
        } catch {
            self.message = Message(error.localizedDescription, level: .error)
        }
    }
}
