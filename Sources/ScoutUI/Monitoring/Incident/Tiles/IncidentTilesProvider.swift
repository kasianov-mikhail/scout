//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

@MainActor
final class IncidentTilesProvider<Element: RecordDecodable & Incident>: ObservableObject, Provider {
    typealias Output = [IncidentTile<Element>]

    @Published var result: ProviderResult<[IncidentTile<Element>]>?
    @Published var message: Message?
    @Published var range: IncidentRange

    private let feed = IncidentProvider<Element>()
    private var loadedRange: Range<Date>?

    init(range: IncidentRange = .week, _ result: ProviderResult<[IncidentTile<Element>]>? = nil) {
        self.range = range
        self.result = result
    }

    func fetch(in database: DatabaseReader) async throws -> [IncidentTile<Element>] {
        let now = Date()
        let current = range.range(now: now)
        let previous = range.previousRange(now: now)

        async let currentIndex = database.incidentIndex(recordType: Element.recordType, in: current)
        async let previousIndex = database.incidentIndex(recordType: Element.recordType, in: previous)

        if loadedRange != current {
            feed.clear()
            loadedRange = current
        }

        await feed.fetchLatest(in: database, range: current)

        try Task.checkCancellation()

        if feed.records == nil, let error = feed.error {
            throw error
        }

        return IncidentTile.tiles(
            records: feed.records ?? [],
            keys: feed.keys,
            current: try? await currentIndex,
            previous: try? await previousIndex,
            range: current
        )
    }
}
