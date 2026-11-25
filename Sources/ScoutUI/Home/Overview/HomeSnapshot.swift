//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct HomeSnapshot {
    static let date = Calendar.utc.date(from: DateComponents(year: 2026, month: 10, day: 25))!

    let alerts: AlertHistory
    let users: ActiveUsers
    let telemetry: [TelemetryItem]
    let releases: ReleaseAdoption
    let retention: [RetentionWeek]
}

extension HomeSnapshot {
    init?(alerts: ProviderResult<[AlertStatus]>?, activity: ProviderResult<[ActivityPoint]>?, sessions: ProviderResult<[ChartPoint<Int>]>?, releases: ProviderResult<[ReleaseHealth]>?, retention: ProviderResult<[RetentionCohort]>?, devices: ProviderResult<[DeviceSummary]>?, report: [LogCategory: Trend]?) {
        guard case .success(let statuses)? = alerts, case .success(let points)? = activity else {
            return nil
        }
        guard case .success(let sessionPoints)? = sessions, case .success(let releaseList)? = releases else {
            return nil
        }
        guard case .success(let cohorts)? = retention, case .success(let deviceList)? = devices else {
            return nil
        }
        guard let report else {
            return nil
        }

        self.init(
            alerts: AlertHistory(statuses: statuses),
            users: ActiveUsers(activity: points, sessions: sessionPoints, devices: deviceList),
            telemetry: [TelemetryItem](report: report, resources: releaseList),
            releases: ReleaseAdoption(releases: releaseList),
            retention: [RetentionWeek](cohorts: cohorts)
        )
    }
}
