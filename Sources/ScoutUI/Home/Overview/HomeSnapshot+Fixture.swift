//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension HomeSnapshot {
    static let sample = HomeSnapshot(
        alerts: .sample,
        users: .sample,
        telemetry: TelemetryItem.sample,
        releases: .sample,
        retention: [RetentionWeek].samples
    )

    static let empty = HomeSnapshot(
        alerts: AlertHistory(statuses: []),
        users: ActiveUsers(
            metrics: ActiveUsers.Kind.allCases.map {
                ActiveUsersMetric(kind: $0, series: Array(repeating: 0, count: 30))
            },
            start: date.addingDay(-29),
            end: date,
            monthlyUsers: 0,
            medianSession: nil,
            newDevicesToday: false,
            devicesThisWeek: 0
        ),
        telemetry: [TelemetryItem](report: [:], resources: []),
        releases: ReleaseAdoption(releases: []),
        retention: []
    )
}
