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
        self.init(
            path: .constant([]),
            activities: ActivityProvider().holding(activities),
            retention: RetentionProvider().holding(retention),
            sessions: StatProvider(eventName: "Session", periods: Period.summary).holding(sessions),
            releases: ReleaseHealthProvider().holding(releases),
            logs: HomeLogProvider().holding(acrossAllPeriods: logs),
            devices: DevicesProvider().holding(devices),
            alerts: AlertProvider().holding(alerts)
        )
    }
}
