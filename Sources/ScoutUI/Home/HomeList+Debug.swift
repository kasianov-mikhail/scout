//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

extension HomeList {
    init(alerts: [AlertStatus]?, releases: [ReleaseHealth]?) {
        let activities = ActivityProvider()
        activities.result = .success(.samples)

        let sessions = StatProvider(eventName: "Session", periods: Period.summary)
        sessions.result = .success(.samples)

        let retention = RetentionProvider()
        retention.result = .success(.samples)

        let devices = DevicesProvider()
        devices.result = .success(.sample)

        let logs = HomeLogProvider()
        for period in Period.allCases {
            logs.period = period
            logs.result = .success(HomeLogProvider.sample(for: period))
        }
        logs.period = .today

        let alertProvider = AlertProvider()
        alertProvider.result = alerts.map { .success($0) }

        let releaseProvider = ReleaseHealthProvider()
        releaseProvider.result = releases.map { .success($0) }

        self.init(
            path: .constant([]),
            activities: activities,
            retention: retention,
            sessions: sessions,
            releases: releaseProvider,
            logs: logs,
            devices: devices,
            alerts: alertProvider
        )
    }
}
