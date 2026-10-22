//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension Session: Fixture {
    static func sample(minutesAgo: Double, launchID: UUID, installID: UUID, ongoing: Bool = false) -> Session {
        let startDate = Date(timeIntervalSinceNow: -minutesAgo * 60)
        let sessionID = UUID()
        return Session(
            startDate: startDate,
            endDate: ongoing ? nil : startDate.addingTimeInterval(120),
            id: sessionID.uuidString,
            sessionID: sessionID,
            launchID: launchID,
            installID: installID
        )
    }

    static var samples: [Session] {
        let launchID = UUID()
        let installID = UUID()
        return [
            .sample(minutesAgo: 0, launchID: launchID, installID: installID, ongoing: true),
            .sample(minutesAgo: 45, launchID: launchID, installID: installID),
        ]
    }
}
