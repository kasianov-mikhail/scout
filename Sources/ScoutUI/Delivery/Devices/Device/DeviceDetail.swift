//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct DeviceDetail {
    let summary: DeviceSummary
    let crashes: Int
    let hangs: Int
    let resources: Int
    let recentSessions: [DeviceSession]
    let history: [DeviceHistoryEvent]
    let activity: [DeviceActivityPoint]
    let usage: DeviceUsage
    let range: IncidentRange
    let medianDuration: TimeInterval?

    var maxSessionDuration: TimeInterval {
        recentSessions.compactMap(\.duration).max() ?? 0
    }

    var activeDaysLabel: String {
        let active = activity.filter { $0.count > 0 }.count
        let unit = range == .year ? "month" : "day"
        return "\(active) of \(activity.count) \(unit)s"
    }

    var activityCaption: String {
        let unit = range == .year ? "month" : "day"
        var parts = ["Sessions per \(unit)"]

        if let medianDuration {
            parts.append("median length \(medianDuration.deviceLength)")
        }
        if let window = usage.busiestWindow {
            parts.append("most active \(window)")
        }

        return parts.joined(separator: " · ")
    }

    var usageCaption: String {
        guard let window = usage.busiestWindow else {
            return "No sessions in this period"
        }
        return "Most activity \(window), in UTC"
    }
}
