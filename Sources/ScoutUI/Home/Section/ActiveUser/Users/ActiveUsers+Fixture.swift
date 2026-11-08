//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension ActiveUsers {
    static let sample: ActiveUsers = {
        let end = HomeSnapshot.date

        return ActiveUsers(
            metrics: [
                ActiveUsersMetric(
                    kind: .dau,
                    value: 1212,
                    delta: 0.041,
                    series: [
                        1083, 1119, 1138, 1101, 1065, 1119, 1156, 1083, 1138, 1156,
                        1119, 1083, 1138, 1174, 1119, 1138, 1174, 1156, 1101, 1156,
                        1174, 1138, 1192, 1282, 1228, 1101, 1246, 1300, 1174, 1212,
                    ]
                ),
                ActiveUsersMetric(
                    kind: .sessions,
                    value: 8412,
                    delta: 0.123,
                    series: [
                        7200, 7440, 7560, 7320, 7080, 7440, 7680, 7200, 7560, 7680,
                        7440, 7200, 7560, 7800, 7440, 7560, 7800, 7680, 7320, 7680,
                        7800, 7560, 7920, 8520, 8160, 7320, 8280, 8640, 7800, 8412,
                    ]
                ),
                ActiveUsersMetric(
                    kind: .devices,
                    value: 38,
                    delta: 0.12,
                    series: [
                        33, 34, 35, 34, 32, 34, 35, 33, 34, 35,
                        34, 33, 35, 36, 34, 35, 36, 35, 34, 35,
                        36, 35, 37, 39, 38, 34, 38, 39, 36, 38,
                    ]
                ),
            ],
            start: end.addingDay(-29),
            end: end,
            monthlyUsers: 14259,
            medianSession: 252,
            newDevicesToday: true,
            devicesThisWeek: 254
        )
    }()
}
