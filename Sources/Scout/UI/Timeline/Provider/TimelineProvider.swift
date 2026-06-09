//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import SwiftUI

@MainActor
final class TimelineProvider: ObservableObject {
    @Published var result: Result<Rail, Error>?

    let older = RailLane(ascending: false)
    let newer = RailLane(ascending: true)

    func start(feed: TimelineFeed, anchorEvent: Event?, eventName: String?) async {
        result = nil
        older.eventName = eventName
        newer.eventName = eventName

        do {
            let rail = try await feed.rail()

            guard let split = rail.split(at: anchorEvent) else {
                return
            }

            older.pendingInstalls = split.older
            newer.pendingInstalls = split.newer

            var sessions: [Session] = []
            var events: [Event] = []

            while events.count < 50 {
                let lanes = [older, newer].filter { $0.pendingInstalls.count > 0 }

                guard lanes.count > 0 else {
                    break
                }

                for lane in lanes {
                    let chunk = try await lane.loadMore(in: feed.database)
                    sessions += chunk.sessions
                    events += chunk.events
                }
            }

            result = .success(rail.merged(sessions: sessions, events: events))
        } catch {
            result = .failure(error)
        }
    }
}

extension TimelineFeed {
    fileprivate func rail() async throws -> Rail {
        try await Rail(
            device: device(),
            installs: installs(),
            launches: launches()
        )
    }
}
