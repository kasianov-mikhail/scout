//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import SwiftUI

extension TimelineRowsBuilder {
    mutating func appendLaunch(_ root: LaunchRoot) {
        guard let start = root.launch.startDate else {
            return
        }

        if let previousEnd {
            appendGap(from: previousEnd, to: start)
        }

        let launch = root.launch
        let version = launch.launchID.flatMap { versionByLaunch[$0] }
        let boundary = launchBounds[start]
        let fullyLoaded = isFullyLoaded(start: start, boundary: boundary)
        let launchCrashes = crashesForLaunch(start: start, end: boundary)
        let sessionCrashes = root.sessions.contains { session in
            guard let id = session.session.sessionID else {
                return false
            }
            return crashesBySession[id]?.isEmpty == false
        }
        let endsWithCrash = sessionCrashes || !launchCrashes.isEmpty
        let live = launch.launchID == lastLaunchID && launch.endDate == nil && !endsWithCrash
        let subtitle = launchSubtitle(root, version: version, start: start, hasCrash: !launchCrashes.isEmpty, fullyLoaded: fullyLoaded)
        let startsAtCenter = entries.contains { $0.kind == .launch }

        entries.append(
            TimelineEntry(
                id: "launch-\(launch.id)",
                kind: .launch,
                height: Self.rowHeight,
                launch: TimelineEntry.Lane(color: .timelineLaunch, dashed: false, top: startsAtCenter ? Self.rowHeight / 2 : 0, bottom: 0),
                session: nil,
                connector: nil,
                marker: .milestone(symbol: "play.fill", color: .timelineLaunch),
                title: label("App launched", size: 15, weight: .semibold, color: .primary),
                subtitle: subtitle.map { label($0, size: 13, weight: .regular, color: .timelineMuted) },
                time: start.timelineTime,
                chip: nil,
                tint: nil
            )
        )

        for crash in launchCrashes.sorted(byDate: \.date) {
            if let date = crash.date {
                appendLaunchCrash(crash, date: date)
            }
        }

        for (index, session) in root.sessions.enumerated() {
            appendSession(
                session,
                isLast: index == root.sessions.count - 1,
                live: live
            )
        }

        if !endsWithCrash {
            if let end = launch.endDate {
                if root.sessions.isEmpty && fullyLoaded {
                    appendClose(launch, date: end)
                }
            } else if !live && fullyLoaded {
                appendUnknown(root, crashes: launchCrashes)
            }
        }

        previousEnd = activityEnd(root, crashes: launchCrashes)
        previousVersion = version ?? previousVersion
        previousLaunchDay = start
    }
}
