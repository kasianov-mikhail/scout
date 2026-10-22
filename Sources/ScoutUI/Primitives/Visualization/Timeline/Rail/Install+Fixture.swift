//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension Install: Fixture {
    static func sample(minutesAgo: Double, deviceID: UUID) -> Install {
        let installID = UUID()
        return Install(
            date: Date(timeIntervalSinceNow: -minutesAgo * 60),
            id: installID.uuidString,
            installID: installID,
            deviceID: deviceID
        )
    }

    static var samples: [Install] {
        let deviceID = UUID()
        return [
            .sample(minutesAgo: 0, deviceID: deviceID),
            .sample(minutesAgo: 4320, deviceID: deviceID),
        ]
    }
}
