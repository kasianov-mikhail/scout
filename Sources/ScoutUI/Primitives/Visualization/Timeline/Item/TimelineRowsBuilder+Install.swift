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
    mutating func appendInstall(_ root: InstallRoot, isFirst: Bool) {
        let launches = root.launches.filter(isLaunchVisible)
        guard !launches.isEmpty || root.launches.isEmpty else {
            return
        }

        let install = root.install
        let date = install.date ?? launches.first?.launch.startDate

        if let date {
            if let previousEnd {
                appendGap(from: previousEnd, to: date)
            }
            appendInstallMilestone(install, date: date, isFirst: isFirst, startsRail: entries.isEmpty)
            previousEnd = date
        }

        previousVersion = nil
        previousLaunchDay = nil

        for launch in launches {
            appendLaunch(launch)
        }
    }

    private mutating func appendInstallMilestone(_ install: Install, date: Date, isFirst: Bool, startsRail: Bool) {
        entries.append(
            TimelineEntry(
                id: "install-\(install.id)",
                kind: .install,
                height: Self.rowHeight,
                launch: TimelineEntry.Lane(
                    color: .timelinePending,
                    dashed: true,
                    top: startsRail ? Self.rowHeight / 2 : 0,
                    bottom: startsRail ? 0 : Self.rowHeight / 2
                ),
                session: nil,
                connector: nil,
                marker: .milestone(symbol: "arrow.down.to.line", color: .timelineInstall),
                title: label(isFirst ? "App installed" : "App reinstalled", size: 15, weight: .semibold, color: .primary),
                subtitle: label(isFirst ? date.timelineDay : "\(date.timelineDay) · new install", size: 13, weight: .regular, color: .timelineMuted),
                time: date.timelineTime,
                chip: nil,
                tint: nil
            )
        )
    }

    private func isLaunchVisible(_ root: LaunchRoot) -> Bool {
        if !root.sessions.isEmpty {
            return true
        }

        guard let start = root.launch.startDate else {
            return false
        }

        let boundary = launchBounds[start]

        if let focusDate = focus?.date {
            if focusDate >= start && (boundary.map { focusDate < $0 } ?? true) {
                return true
            }
        }

        guard let loadedRange else {
            return true
        }

        if loadedRange.contains(start) {
            return true
        }

        if start < loadedRange.lowerBound {
            return reachesStart
        }

        return reachesEnd
    }
}
