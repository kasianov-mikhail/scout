//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import SwiftUI

@MainActor
final class TimelineProvider: ObservableObject {
    @Published var result: Result<Rail, Error>? {
        didSet {
            updateDerivedState()
        }
    }

    private(set) var entries: [TimelineEntry] = []

    private(set) var exportText: String?

    let older = RailLane(ascending: false)
    let newer = RailLane(ascending: true)

    var incidents = TimelineIncidents()

    private var focus: TimelineFocus?

    private var startToken = Epoch()

    func start(feed: TimelineFeed, anchor: TimelineAnchor?, focus: TimelineFocus?) async {
        let token = Epoch()
        startToken = token
        self.focus = focus
        incidents = TimelineIncidents()

        for lane in [older, newer] {
            lane.reset(anchor: anchor?.date)
        }

        result = nil

        do {
            async let rail = feed.rail()
            async let fetched = feed.incidents()

            let railValue = try await rail
            let fetchedValue = try await fetched
            let versions = try await feed.versions(installIDs: railValue.installs.compactMap(\.install.installID))

            guard token == startToken else {
                return
            }

            incidents = TimelineIncidents(
                crashes: fetchedValue.crashes,
                hangs: fetchedValue.hangs,
                resources: fetchedValue.resources,
                versions: versions
            )

            let split: (older: [UUID], newer: [UUID])
            if let anchored = railValue.split(anchor: anchor) {
                split = anchored
            } else {
                for lane in [older, newer] {
                    lane.anchorDate = nil
                }
                split = (older: [], newer: railValue.installs.compactMap(\.install.installID))
            }

            older.pendingInstalls = split.older
            newer.pendingInstalls = split.newer

            var sessions: [Session] = []
            var events: [Event] = []

            while events.count(where: { $0.date != nil }) < 50 {
                guard token == startToken else {
                    throw CancellationError()
                }

                let lanes = [older, newer].filter { !$0.pendingInstalls.isEmpty }

                guard !lanes.isEmpty else {
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

            guard token == startToken else {
                return
            }

            result = .success(railValue.merged(sessions: sessions, events: events))
        } catch is CancellationError {
            return
        } catch {
            if token == startToken {
                result = .failure(error)
            }
        }
    }

    private func updateDerivedState() {
        switch result {
        case .success(let rail):
            entries =
                TimelineRows(
                    rail: rail,
                    incidents: incidents,
                    focus: focus,
                    now: Date(),
                    reachesStart: older.pendingInstalls.isEmpty && !older.isLoading,
                    reachesEnd: newer.pendingInstalls.isEmpty && !newer.isLoading
                ).entries
            exportText = TimelineExport(rail: rail).text
        case .failure, nil:
            entries = []
            exportText = nil
        }
    }
}
