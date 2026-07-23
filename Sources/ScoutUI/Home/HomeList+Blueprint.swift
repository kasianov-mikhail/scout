//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

extension HomeList {
    init(
        activities: [ActivityPoint]?,
        retention: [RetentionCohort]?,
        sessions: [ChartPoint<Int>]?,
        releases: [ReleaseHealth]?,
        logs: [MetricSeries]?,
        devices: DevicesReport?,
        alerts: [AlertStatus]?
    ) {
        let activitiesProvider = ActivityProvider()
        activitiesProvider.result = activities.map { .success($0) }

        let retentionProvider = RetentionProvider()
        retentionProvider.result = retention.map { .success($0) }

        let sessionsProvider = StatProvider(eventName: "Session", periods: Period.summary)
        sessionsProvider.result = sessions.map { .success($0) }

        let releasesProvider = ReleaseHealthProvider()
        releasesProvider.result = releases.map { .success($0) }

        let logsProvider = HomeLogProvider()
        if let logs {
            for period in Period.allCases {
                logsProvider.period = period
                logsProvider.result = .success(logs)
            }
            logsProvider.period = .today
        }

        let devicesProvider = DevicesProvider()
        devicesProvider.result = devices.map { .success($0) }

        let alertsProvider = AlertProvider()
        alertsProvider.result = alerts.map { .success($0) }

        self.init(
            path: .constant([]),
            activities: activitiesProvider,
            retention: retentionProvider,
            sessions: sessionsProvider,
            releases: releasesProvider,
            logs: logsProvider,
            devices: devicesProvider,
            alerts: alertsProvider
        )
    }
}
