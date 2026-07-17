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
    @Published var result: Result<Rail, Error>? {
        didSet {
            let rail = try? result?.get()
            items = rail.map(TimelineItem.items(from:)) ?? []
            exportText = rail.flatMap { TimelineExport(rail: $0).text }
        }
    }

    // Derived from `result` once per change, so view body re-evaluations
    // (legend toggles, scroll) don't rebuild the row list from the tree.
    private(set) var items: [TimelineItem] = []

    // The Markdown export of `result`, rebuilt once per change rather than
    // on every toolbar render.
    private(set) var exportText: String?

    let older = RailLane(ascending: false)
    let newer = RailLane(ascending: true)

    // Identifies the latest `start` call; a superseded call that survives its
    // awaits must not publish a result over the newer one's.
    private var startToken = Epoch()

    func start(feed: TimelineFeed, anchorEvent: Event?, eventName: String?) async {
        let token = Epoch()
        startToken = token

        result = nil

        for lane in [older, newer] {
            lane.eventName = eventName
            lane.anchorDate = anchorEvent?.date
        }

        do {
            let rail = try await feed.rail()

            let split: (older: [UUID], newer: [UUID])
            if let anchored = rail.split(at: anchorEvent) {
                split = anchored
            } else {
                // No usable anchor (no event, or its install isn't in the
                // rail yet): load the whole timeline from its start through
                // the ascending lane instead of spinning forever.
                for lane in [older, newer] {
                    lane.anchorDate = nil
                }
                split = (older: [], newer: rail.installs.compactMap(\.install.installID))
            }

            older.pendingInstalls = split.older
            newer.pendingInstalls = split.newer

            var sessions: [Session] = []
            var events: [Event] = []

            // Count only events that will actually render: `TimelineItem.items`
            // drops events without a date, so raw counts overestimate the seed.
            while events.count(where: { $0.date != nil }) < 50 {
                // A newer `start` owns the lanes now; bail out before touching
                // them, or this loop would consume the chunks it seeds with.
                guard token == startToken else {
                    throw CancellationError()
                }

                let lanes = [older, newer].filter { $0.pendingInstalls.count > 0 }

                guard lanes.count > 0 else {
                    break
                }

                try await withThrowingTaskGroup(of: (sessions: [Session], events: [Event]).self) { group in
                    for lane in lanes {
                        group.addTask {
                            try await lane.loadMore(in: feed.database)
                        }
                    }
                    for try await chunk in group {
                        sessions += chunk.sessions
                        events += chunk.events
                    }
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
        async let device = self.device()
        async let installs = self.installs()
        async let launches = self.launches()
        return try await Rail(
            device: device,
            installs: installs,
            launches: launches
        )
    }
}
