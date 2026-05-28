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

    var pendingInstalls: [UUID] = []
    var sessionCursor: CKQueryOperation.Cursor?
    var range: DateInterval?

    let sessionsPerBatch = 10

    func start(deviceID: UUID, range: DateInterval? = nil, in database: AppDatabase) async {
        guard pagination != .loading else { return }
        pagination = .loading

        self.range = range

        do {
            let root = RailRoot(deviceID: deviceID, range: range, database: database)
            let rail = try await root.load()

            result = rail.map(ProviderResult.success)

            pendingInstalls =
                rail?
                .installs
                .map(\.install)
                .sorted(byDate: \.date, ascending: false)
                .compactMap(\.installID) ?? []

            sessionCursor = nil
            pagination = pendingInstalls.isEmpty ? .exhausted : .idle
        } catch {
            result = .failure(error)
            pagination = .idle
        }
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
