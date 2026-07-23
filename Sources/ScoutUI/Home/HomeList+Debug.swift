//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

#if DEBUG
    extension HomeList {
        init(alerts: [AlertStatus]?, releases: [ReleaseHealth]?) {
            self.init(
                path: .constant([]),
                activities: ActivityProvider(),
                retention: RetentionProvider(),
                sessions: StatProvider(eventName: "Session", periods: Period.summary),
                releases: ReleaseHealthProvider(),
                logs: HomeLogProvider(),
                devices: DevicesProvider(),
                alerts: AlertProvider()
            )

            activities.result = .success(.samples)
            sessions.result = .success(.samples)
            retention.result = .success(.samples)
            devices.result = .success(.sample)

            for period in Period.allCases {
                logs.period = period
                logs.result = .success(HomeLogProvider.sample(for: period))
            }
            logs.period = .today

            self.alerts.result = alerts.map { .success($0) }
            self.releases.result = releases.map { .success($0) }
        }
    }
#endif
