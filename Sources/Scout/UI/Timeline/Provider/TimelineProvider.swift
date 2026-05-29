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
            let rail = try await root.load()

            pendingInstalls = rail?.pendingInstalls ?? []
            sessionCursor = nil

            if let rail {
                result = pendingInstalls.isEmpty ? .exhausted(rail) : .loaded(rail)
            } else {
                result = .idle
            }
        } catch {
            result = .failure(error)
        }
    }

    func loadMore(in database: AppDatabase) async {
        guard case .loaded(let rail) = result, let installID = pendingInstalls.first else {
            return
        }

        result = .paging(rail)

        do {
            let page = RailPage(installID: installID, range: range, cursor: sessionCursor, database: database)
            let (sessions, events, cursor) = try await page.load()
            let rail = rail.merged(sessions: sessions, events: events)

            if let cursor {
                sessionCursor = cursor
            } else {
                pendingInstalls.removeFirst()
                sessionCursor = nil
            }
            result = pendingInstalls.isEmpty ? .exhausted(rail) : .loaded(rail)
        } catch {
            result = .failure(error)
        }
    }
}
