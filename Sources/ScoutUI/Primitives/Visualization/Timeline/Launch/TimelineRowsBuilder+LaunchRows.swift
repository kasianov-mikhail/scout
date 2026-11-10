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
    mutating func appendLaunchCrash(_ crash: Crash, date: Date) {
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

    mutating func appendClose(_ launch: Launch, date: Date) {
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

    mutating func appendUnknown(_ root: LaunchRoot, crashes: [Crash]) {
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
}

extension Crash {
    fileprivate var noSessionSubtitle: String {
        if case .metricKit = source {
            return "no session · MetricKit"
        }
        return "no session"
    }
}
