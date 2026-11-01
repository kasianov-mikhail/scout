//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension AlertHistory {
    init(statuses: [AlertStatus]) {
        let firing = statuses.filter(\.isFiring)

        self.init(
            buckets: statuses.buckets,
            rule: (firing.first ?? statuses.first)?.rule.metric.title ?? "Alerts",
            firing: firing.count,
            armed: statuses.filter(\.isArmed).count,
            muted: statuses.filter(\.isMuted).count,
            total: statuses.count
        )
    }
}
