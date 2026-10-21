//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

@MainActor
final class IncidentProvider<Element: RecordDecodable & Incident>: FeedProvider<Element>, Refreshable {
    @Published private(set) var keys: [String: String] = [:]

    var groups: [IncidentGroup<Element>]? {
        records.map { IncidentGroup.groups(from: $0, keys: keys) }
    }

    func fetchLatest(in database: DatabaseReader) async {
        await fetchLatest(matching: Element.query(), in: database)
        await loadKeys(incidents: records ?? [], in: database)
    }

    func fetchAgain(in database: DatabaseReader) async {
        await fetchAgain(matching: Element.query(), in: database)
        await loadKeys(incidents: records ?? [], in: database)
    }

    @discardableResult
    override func fetchMore(cursor: RecordCursor, in database: RecordReader) async -> Bool {
        let loaded = Set(records?.map(\.id) ?? [])
        let succeeded = await super.fetchMore(cursor: cursor, in: database)

        await loadKeys(
            incidents: records?.filter { !loaded.contains($0.id) } ?? [],
            in: database
        )
        return succeeded
    }

    private func loadKeys(incidents: [Element], in database: RecordReader) async {
        let dates = incidents.compactMap(\.date)

        guard let first = dates.min(), let last = dates.max() else {
            return
        }
        do {
            let loaded = try await IncidentBacktraces(
                range: first..<last.addingTimeInterval(1),
                database: database
            )
            .groupKeys

            keys.merge(loaded) { $1 }
        } catch {
            print("Failed to load incident backtraces: \(error)")
        }
    }
}
