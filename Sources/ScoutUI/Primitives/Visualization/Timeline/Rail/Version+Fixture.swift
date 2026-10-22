//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension Version: Fixture {
    static func sample(appVersion: String, buildNumber: String, minutesAgo: Double) -> Version {
        Version(
            appVersion: appVersion,
            buildNumber: buildNumber,
            launchID: UUID(),
            date: Date(timeIntervalSinceNow: -minutesAgo * 60),
            id: UUID().uuidString
        )
    }

    static var samples: [Version] {
        [
            .sample(appVersion: "2.4.1", buildNumber: "214", minutesAgo: 0),
            .sample(appVersion: "2.4.0", buildNumber: "210", minutesAgo: 4320),
        ]
    }
}
