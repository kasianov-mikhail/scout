//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

#if DEBUG
    extension HomeAlertSection {
        init(statuses: [AlertStatus]) {
            let alerts = AlertProvider()
            alerts.result = .success(statuses)

            self.init(alerts: alerts, path: .constant([]))
        }
    }
#endif
