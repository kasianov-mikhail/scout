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
    @Published private(set) var older = RailLane()
    @Published private(set) var newer = RailLane()

    func start(feed: TimelineFeed, anchorEvent: Event?, eventName: String?) async {
        result = nil
        older = RailLane(eventName: eventName)
        newer = RailLane(eventName: eventName)

        do {
            let rail = try await feed.rail()

            guard let split = rail.split(at: anchorEvent) else {
                return
            }

            older.pendingInstalls = split.older
            newer.pendingInstalls = split.newer

            // Seed the first chunk of both lanes before showing the list, so the
            // user goes straight from the loading spinner to events instead of
            // flashing an empty list while the pagination footers self-load.
            var seeded = rail

            for lane in [older, newer] where !lane.pendingInstalls.isEmpty {
                let (sessions, events) = try await lane.loadMore(in: feed.database)
                seeded = seeded.merged(sessions: sessions, events: events)
            }

            result = .success(seeded)
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
