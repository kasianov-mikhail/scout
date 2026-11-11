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

        let index = try await currentIndex

        return IncidentTile.tiles(
            records: feed.records ?? [],
            legacy: try await legacyRecords(in: database, index: index, range: current),
            keys: feed.keys,
            current: index,
            previous: try await previousIndex,
            range: current
        )
    }

    private func legacyRecords(in database: DatabaseReader, index: IncidentIndex?, range: Range<Date>) async throws -> [Element] {
        guard let bounds = index?.unkeyedRange(in: range) else {
            return []
        }
        return try await database.readAll(matching: Element.query(in: bounds), fields: Element.desiredKeys)
    }
}

extension IncidentIndex {
    fileprivate func unkeyedRange(in range: Range<Date>) -> Range<Date>? {
        guard let unkeyed else {
            return nil
        }
        let end = min(unkeyed.upperBound, range.upperBound)
        guard end > range.lowerBound else {
            return nil
        }
        return range.lowerBound..<end
    }
}
