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

        entries.append(
            TimelineEntry(
                id: "launch-\(launch.id)",
                kind: .launch,
                height: Self.rowHeight,
                launch: TimelineEntry.Lane(color: .timelineLaunch, dashed: false, top: 0, bottom: 0),
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
                appendUnknown(root, start: start, crashes: launchCrashes)
            }
        }

        previousEnd = activityEnd(root, crashes: launchCrashes)
        previousVersion = version ?? previousVersion
        previousLaunchDay = start
    }

    private func isFullyLoaded(start: Date, boundary: Date?) -> Bool {
        guard let loadedRange else {
            return true
        }

        if start < loadedRange.lowerBound {
            return reachesStart
        }
        if start > loadedRange.upperBound {
            return reachesEnd
        }
        if reachesEnd {
            return true
        }
        if let boundary {
            return boundary <= loadedRange.upperBound
        }
        return false
    }

    private func crashesForLaunch(start: Date, end: Date?) -> [Crash] {
        incidents.crashes.filter { crash in
            guard crash.sessionID == nil, let date = crash.date else {
                return false
            }
            guard date >= start else {
                return false
            }
            if let end {
                return date < end
            }
            return true
        }
    }

    private func launchSubtitle(_ root: LaunchRoot, version: String?, start: Date, hasCrash: Bool, fullyLoaded: Bool) -> String? {
        if root.sessions.isEmpty && !hasCrash && fullyLoaded {
            return "No sessions"
        }

        if let version, let previousVersion, version != previousVersion {
            return "Updated \(previousVersion) → \(version)"
        }

        if previousLaunchDay == nil {
            return [start.timelineDay, version].compactMap(\.self).joined(separator: " · ")
        }

        if let previousLaunchDay, !Calendar.utc.isDate(previousLaunchDay, inSameDayAs: start) {
            return start.timelineDay
        }

        return nil
    }

    private mutating func appendLaunchCrash(_ crash: Crash, date: Date) {
        let focused = focus?.id == crash.id

        entries.append(
            TimelineEntry(
                id: crash.id,
                kind: .crash,
                height: Self.rowHeight,
                launch: TimelineEntry.Lane(color: .timelineLaunch, dashed: false, top: 0, bottom: Self.rowHeight / 2),
                session: nil,
                connector: nil,
                marker: .incident(.crash),
                title: label("Crash", size: 16, weight: .semibold, color: .timelineCrashInk),
                subtitle: label(crash.noSessionSubtitle, size: 13, weight: .regular, color: .timelineMuted, monospaced: true),
                time: date.timelineSecond,
                chip: focused ? focus?.chip : nil,
                tint: focused ? Color.timelineCrash.opacity(0.1) : nil
            )
        )
    }

    private mutating func appendClose(_ launch: Launch, date: Date) {
        entries.append(
            TimelineEntry(
                id: "close-\(launch.id)",
                kind: .close,
                height: Self.rowHeight,
                launch: TimelineEntry.Lane(color: .timelineLaunch, dashed: false, top: 0, bottom: Self.rowHeight / 2),
                session: nil,
                connector: nil,
                marker: .milestone(symbol: "stop.fill", color: .timelineLaunch),
                title: label("App closed", size: 15, weight: .semibold, color: .primary),
                subtitle: nil,
                time: date.timelineTime,
                chip: nil,
                tint: nil
            )
        )
    }

    private mutating func appendUnknown(_ root: LaunchRoot, start: Date, crashes: [Crash]) {
        let lastSeen = activityEnd(root, crashes: crashes)

        entries.append(
            TimelineEntry(
                id: "unknown-\(root.launch.id)",
                kind: .unknown,
                height: Self.rowHeight,
                launch: TimelineEntry.Lane(color: .timelineLaunch, dashed: false, top: 0, bottom: Self.rowHeight / 2),
                session: nil,
                connector: nil,
                marker: .milestone(symbol: "questionmark", color: .timelineUnknown),
                title: label("App end not recorded", size: 15, weight: .regular, color: .timelineMuted),
                subtitle: label("last seen \(lastSeen.timelineTime)", size: 13, weight: .regular, color: .timelineMuted),
                time: nil,
                chip: nil,
                tint: nil
            )
        )
    }

    private func activityEnd(_ root: LaunchRoot, crashes: [Crash]) -> Date {
        var dates = root.sessions.flatMap(\.events).compactMap(\.date)
        dates += root.sessions.compactMap(\.session.startDate)
        dates += root.sessions.compactMap(\.session.endDate)
        dates += crashes.compactMap(\.date)

        for session in root.sessions {
            guard let id = session.session.sessionID else {
                continue
            }
            dates += crashesBySession[id]?.compactMap(\.date) ?? []
            dates += hangsBySession[id]?.compactMap(\.date) ?? []
            dates += resourcesBySession[id]?.compactMap(\.date) ?? []
        }

        if let end = root.launch.endDate {
            dates.append(end)
        }

        return dates.max() ?? root.launch.startDate ?? .distantPast
    }
}

extension Crash {
    fileprivate var noSessionSubtitle: String {
        if case .metricKit = source {
            return "no session · MetricKit"
        }
        return "no session"
    }
}
