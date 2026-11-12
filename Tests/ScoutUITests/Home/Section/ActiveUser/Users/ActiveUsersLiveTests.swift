//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import Testing

@testable import ScoutUI

struct ActiveUsersLiveTests {
    @Test("Providers map to three 30-day metrics")
    func metrics() {
        let users = ActiveUsers(
            activity: ActivityPoint.samples,
            sessions: ChartPoint<Int>.samples,
            devices: DeviceSummary.samples
        )

        #expect(users.metrics.map(\.kind) == [.dau, .sessions, .devices])
        #expect(users.metrics.allSatisfy { $0.series.count == 30 })
        #expect(users.metrics.allSatisfy { $0.series.last == $0.value })
        #expect(users.medianSession == nil)
        #expect(!users.newDevicesToday)
        #expect(users.devicesThisWeek > 0)
    }

    @Test("Ratios read from the latest values")
    func ratios() {
        let start = Date().startOfDay.addingDay(-29)
        let sessions = (0..<30).map { day in
            ChartPoint(date: start.addingDay(day), value: 100 + day)
        }
        let users = ActiveUsers(
            activity: ActivityPoint.samples,
            sessions: sessions,
            devices: DeviceSummary.samples
        )

        #expect(users.stickiness > 0)
        #expect(users.sessionsPerUser > 0)
    }

    @Test("No activity makes the section empty")
    func empty() {
        let users = ActiveUsers(activity: [], sessions: [], devices: [])

        #expect(users.isEmpty)
        #expect(!ActiveUsers.sample.isEmpty)
    }
}
