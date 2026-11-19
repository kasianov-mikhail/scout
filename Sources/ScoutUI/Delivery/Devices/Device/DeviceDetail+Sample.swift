//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension DeviceDetail {
    static var sample: DeviceDetail {
        let now = Date()
        let sessions = (0..<5).map { index in
            let start = now.addingTimeInterval(-Double(index) * 3_600 - 600)
            return DeviceSession(
                id: UUID().uuidString,
                sessionID: UUID(),
                startDate: start,
                endDate: start.addingTimeInterval(Double(5 - index) * 60),
                appVersion: "2.4.1",
                crashed: index == 1
            )
        }
        let sessionCounts = [96, 120, 88, 0, 140, 130, 146]
        let activity = (0..<7).map { index in
            DeviceActivityPoint(
                date: now.startOfDay.addingDay(index - 6),
                label: deviceWeekdayFormatter.string(from: now.startOfDay.addingDay(index - 6)),
                count: sessionCounts[index],
                showsLabel: true,
                isCurrent: index == 6
            )
        }
        let usageCounts: [[Int]] = (0..<7).map { day in
            (0..<24).map { hour in
                let peak: Double = exp(-pow(Double(hour) - 20, 2) / 8)
                let weekday: Double = day < 5 ? 1 : 0.6
                return max(0, Int((peak * weekday + 0.05) * 20))
            }
        }

        return DeviceDetail(
            summary: DeviceSummary.samples[0],
            crashes: 2,
            hangs: 1,
            resources: 2,
            recentSessions: sessions,
            history: [
                DeviceHistoryEvent(id: "updated", date: now.addingTimeInterval(-86_400), kind: .updated(version: "2.4.1")),
                DeviceHistoryEvent(id: "os", date: now.addingTimeInterval(-3 * 86_400), kind: .os(from: "iOS 17.3", to: "iOS 17.4")),
                DeviceHistoryEvent(id: "install", date: now.addingTimeInterval(-9 * 86_400), kind: .installed(version: "2.4.0")),
            ],
            activity: activity,
            usage: DeviceUsage(counts: usageCounts),
            range: .week,
            medianDuration: 240
        )
    }
}
