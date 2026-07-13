//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Launch: Fixture {
    static func sample(minutesAgo: Double = 0, launchID: UUID = UUID(), installID: UUID = UUID(), ongoing: Bool = false)
        -> Launch
    {
        let startDate = Date(timeIntervalSinceNow: -minutesAgo * 60)
        return Launch(
            startDate: startDate,
            endDate: ongoing ? nil : startDate.addingTimeInterval(180),
            id: launchID.uuidString,
            launchID: launchID,
            installID: installID
        )
    }

    static var samples: [Launch] {
        let installID = UUID()
        return [
            .sample(minutesAgo: 0, installID: installID, ongoing: true),
            .sample(minutesAgo: 90, installID: installID),
        ]
    }
}
