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

    /// Identifies the latest `start` call; a superseded call that survives its
    /// awaits must not publish a result over the newer one's.
    private var startToken = UUID()

    func start(feed: TimelineFeed, anchorEvent: Event?, eventName: String?) async {
        let token = UUID()
        startToken = token

        result = nil
        older.eventName = eventName
        newer.eventName = eventName
        older.anchorDate = anchorEvent?.date
        newer.anchorDate = anchorEvent?.date

        do {
            let rail = try await feed.rail()

            guard let split = rail.split(at: anchorEvent) else {
                return
            }

            older.pendingInstalls = split.older
            newer.pendingInstalls = split.newer

            var sessions: [Session] = []
            var events: [Event] = []

            // Count only events that will actually render: `TimelineItem.items`
            // drops events without a date, so raw counts overestimate the seed.
            while events.count(where: { $0.date != nil }) < 50 {
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

            guard token == startToken else { return }

            result = .success(rail.merged(sessions: sessions, events: events))
        } catch is CancellationError {
            // A newer `start` reset the lanes mid-seed; it owns the result now.
        } catch {
            if token == startToken {
                result = .failure(error)
            }
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
