//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

#if DEBUG
    extension HomeLogSection {
        init(period: Period) {
            let log = HomeLogProvider()
            for value in Period.allCases {
                log.period = value
                log.result = .success(HomeLogProvider.sample(for: value))
            }
            log.period = period

            let devices = DevicesProvider()
            devices.result = .success(.sample)

            self.init(period: period, log: log, devices: devices, path: .constant([]))
        }
    }
#endif
