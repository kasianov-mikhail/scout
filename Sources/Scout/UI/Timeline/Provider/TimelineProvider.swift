//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import Foundation
import SwiftUI

@MainActor
final class TimelineProvider: ObservableObject {
    @Published private(set) var result: FeedResult<DeviceRail> = .idle

    var pendingInstalls: [UUID] = []
    var sessionCursor: CKQueryOperation.Cursor?
    var range: DateInterval?

    func start(deviceID: UUID, range: DateInterval? = nil, in database: AppDatabase) async {
        switch result {
        case .loading, .paging, .loaded, .exhausted:
            return
        case .idle, .failure:
            break
        }

        result = .loading

        self.range = range

        do {
            let root = RailRoot(deviceID: deviceID, range: range, database: database)

            guard let rail = try await root.load() else {
                result = .idle
                return
            }

            pendingInstalls = rail.pendingInstalls
            sessionCursor = nil

            // Fold the first content-bearing page into the initial load so the
            // centred loader stays up until there are rows to show, rather than
            // briefly publishing an empty `.loaded`/`.paging` over a blank list.
            var feed = try await loadPage(into: rail, in: database)

            while case .loaded(let rail) = feed, rail.eventCount == 0 {
                feed = try await loadPage(into: rail, in: database)
            }

            result = feed
        } catch {
            result = .failure(error)
        }
    }

    func loadMore(in database: AppDatabase) async {
        guard case .loaded(let rail) = result else {
            return
        }

        result = .paging(rail)

        do {
            result = try await loadPage(into: rail, in: database)
        } catch {
            result = .failure(error)
        }
    }

    private func loadPage(into rail: DeviceRail, in database: AppDatabase) async throws -> FeedResult<DeviceRail> {
        guard let installID = pendingInstalls.first else {
            return .exhausted(rail)
        }

        let page = RailPage(installID: installID, range: range, cursor: sessionCursor, database: database)
        let (sessions, events, cursor) = try await page.load()
        let rail = rail.merged(sessions: sessions, events: events)

        if let cursor {
            sessionCursor = cursor
        } else {
            pendingInstalls.removeFirst()
            sessionCursor = nil
        }
        return pendingInstalls.isEmpty ? .exhausted(rail) : .loaded(rail)
    }
}
