//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension Device: Fixture {
    static func sample(minutesAgo: Double = 0, deviceID: UUID = UUID()) -> Device {
        Device(
            date: Date(timeIntervalSinceNow: -minutesAgo * 60),
            id: deviceID.uuidString,
            deviceID: deviceID
        )
    }

    static var samples: [Device] {
        [
            .sample(minutesAgo: 0),
            .sample(minutesAgo: 4320),
            .sample(minutesAgo: 20160),
        ]
    }
}
