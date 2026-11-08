//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension TimelineRowsBuilder {
    func isFullyLoaded(start: Date, boundary: Date?) -> Bool {
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

    func crashesForLaunch(start: Date, end: Date?) -> [Crash] {
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

    func launchSubtitle(_ root: LaunchRoot, version: String?, start: Date, hasCrash: Bool, fullyLoaded: Bool) -> String? {
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

    func activityEnd(_ root: LaunchRoot, crashes: [Crash]) -> Date {
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
