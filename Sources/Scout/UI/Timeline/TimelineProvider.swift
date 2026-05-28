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
    @Published var result: ProviderResult<DeviceRail>?
    @Published private(set) var pagination: Pagination = .idle
    @Published private(set) var focus: TimelineFocus?

    var pendingInstalls: [UUID] = []
    var sessionCursor: CKQueryOperation.Cursor?
    var range: DateInterval?

    let sessionsPerBatch = 10

    func start(deviceID: UUID, focus: TimelineFocus? = nil, range: DateInterval? = nil, in database: AppDatabase) async {
        guard pagination != .loading else { return }
        pagination = .loading

        self.focus = focus
        self.range = range

        do {
            let root = RailRoot(deviceID: deviceID, range: range, database: database)
            let rail = try await root.load()

            result = rail.map(ProviderResult.success)

            let sortedInstallIDs =
                (rail?.installs ?? [])
                .map(\.install)
                .sorted {
                    ($0.date ?? .distantPast) > ($1.date ?? .distantPast)
                }
                .compactMap(\.installID)

            pendingInstalls = reorderForFocus(sortedInstallIDs, focus: focus)
            sessionCursor = nil
            pagination = pendingInstalls.isEmpty ? .exhausted : .idle
        } catch {
            result = .failure(error)
            pagination = .idle
        }
    }

    private func reorderForFocus(_ installs: [UUID], focus: TimelineFocus?) -> [UUID] {
        guard let focusID = focus?.installID, let idx = installs.firstIndex(of: focusID) else {
            return installs
        }
        var reordered = installs
        reordered.remove(at: idx)
        reordered.insert(focusID, at: 0)
        return reordered
    }

    func loadMore(in database: AppDatabase) async {
        guard pagination == .idle, let installID = pendingInstalls.first, case .success(let rail) = result else {
            return
        }

        pagination = .loading

        do {
            let page = RailPage(installID: installID, range: range, cursor: sessionCursor, limit: sessionsPerBatch, database: database)
            let (sessions, events, cursor) = try await page.load()

            if sessions.count > 0 {
                result = .success(rail.merged(sessions: sessions, events: events))
            }

            if let cursor {
                sessionCursor = cursor
            } else {
                pendingInstalls.removeFirst()
                sessionCursor = nil
            }
            pagination = pendingInstalls.isEmpty ? .exhausted : .idle
        } catch {
            result = .failure(error)
            pagination = .idle
        }
    }
}
