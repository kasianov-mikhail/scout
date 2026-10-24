//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

private let deliveryWindow: TimeInterval = .day

@MainActor
final class IncidentProvider<Element: RecordDecodable & Incident>: FeedProvider<Element>, Refreshable {
    @Published private(set) var keys: [String: String] = [:]

    private var resolved: Set<String> = []

    var groups: [IncidentGroup<Element>]? {
        records.map { IncidentGroup.groups(from: $0, keys: keys, hasMore: cursor != nil) }
    }

    func fetchLatest(in database: DatabaseReader) async {
        await fetchLatest(matching: Element.query(), in: database)
        await loadKeys(in: database)
    }

    func fetchAgain(in database: DatabaseReader) async {
        await fetchAgain(matching: Element.query(), in: database)
        await loadKeys(in: database)
    }

    @discardableResult
    override func fetchMore(cursor: RecordCursor, in database: RecordReader) async -> Bool {
        let succeeded = await super.fetchMore(cursor: cursor, in: database)
        await loadKeys(in: database)
        return succeeded
    }

    private func loadKeys(in database: RecordReader) async {
        let records = records ?? []
        let ids = records.map(\.id)
        let present = Set(ids)
        resolved.formIntersection(present)

        if keys.keys.contains(where: { !present.contains($0) }) {
            keys = keys.filter { present.contains($0.key) }
        }

        let missing = ids.filter { !resolved.contains($0) }
        guard !missing.isEmpty else {
            return
        }

        do {
            let backtraces = try await IncidentBacktraces(
                incidentIDs: missing,
                database: database
            )

            let delivered = Date().addingTimeInterval(-deliveryWindow)
            let settled = records.filter { ($0.date ?? .distantPast) < delivered }.map(\.id)

            resolved.formUnion(backtraces.found)
            resolved.formUnion(settled)
            keys.merge(backtraces.groupKeys) { $1 }
        } catch {
            print("Failed to load incident backtraces: \(error)")
        }
    }
}
