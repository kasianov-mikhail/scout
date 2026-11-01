//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension ActiveUsers {
    init(activity: [ActivityPoint], sessions: [ChartPoint<Int>], devices: [DeviceSummary]) {
        let end = Date().startOfDay
        let start = end.addingDay(-29)
        let range = start..<end.addingDay()

        let dau = Array(activity.points(on: .daily).bucket(in: range, component: .day).reversed()).map(\.value)
        let sessionCounts = Array(sessions.bucket(in: range, component: .day).reversed()).map(\.value)
        let deviceSeries = deviceCounts(devices, start: start)

        self.init(
            metrics: [
                ActiveUsersMetric(kind: .dau, series: dau),
                ActiveUsersMetric(kind: .sessions, series: sessionCounts),
                ActiveUsersMetric(kind: .devices, series: deviceSeries),
            ],
            start: start,
            end: end,
            monthlyUsers: activity.max { $0.date < $1.date }?.mau ?? 0
        )
    }
}

private func deviceCounts(_ devices: [DeviceSummary], start: Date) -> [Int] {
    (0..<30).map { index in
        let day = start.addingDay(index)
        let next = day.addingDay()

        return devices.count { $0.lastSeen >= day && $0.lastSeen < next }
    }
}
