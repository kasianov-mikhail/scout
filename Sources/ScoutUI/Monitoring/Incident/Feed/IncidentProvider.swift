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
    @Published private(set) var tallies: [String: IncidentTally] = [:]

    var groups: [IncidentGroup<Element>]? {
        records.map { IncidentGroup.groups(from: $0, keys: keys, tallies: tallies, hasMore: cursor != nil) }
    }

    func fetchLatest(in database: DatabaseReader) async {
        async let tallied: Void = loadTallies(in: database)
        await fetchLatest(matching: Element.query(), in: database)
        await loadKeys(incidents: records ?? [], in: database)
        await tallied
    }

    func fetchAgain(in database: DatabaseReader) async {
        async let tallied: Void = loadTallies(in: database)
        await fetchAgain(matching: Element.query(), in: database)
        await loadKeys(incidents: records ?? [], in: database)
        await tallied
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

    private func loadTallies(in database: IncidentReader) async {
        if ProcessInfo.processInfo.isPreview {
            return
        }
        do {
            let loaded = try await database.incidentTallies(recordType: Element.recordType, in: Date().trailingYear)
            tallies = Dictionary(loaded.map { ($0.fingerprint, $0) }) { $1 }
        } catch is CancellationError {
            return
        } catch {
            print("Failed to load incident tallies: \(error)")
        }
    }

    private func loadKeys(incidents: [Element], in database: RecordReader) async {
        guard !incidents.isEmpty else {
            return
        }
        do {
            let loaded = try await IncidentBacktraces(
                incidentIDs: incidents.map(\.id),
                database: database
            )
            .groupKeys

            keys.merge(loaded) { $1 }
        } catch {
            print("Failed to load incident backtraces: \(error)")
        }
    }
}
