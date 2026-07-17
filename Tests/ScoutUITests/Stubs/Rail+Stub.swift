//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

@testable import ScoutCore
@testable import ScoutTestSupport
@testable import ScoutUI

extension Rail {
    @discardableResult static func stub(
        deviceID: UUID = UUID(),
        installID: UUID = UUID(),
        launchID: UUID = UUID(),
        sessionID: UUID = UUID(),
        baseDate: Date = Date()
    ) -> Rail {
        Rail(
            device: .stub(deviceID: deviceID, date: baseDate),
            installs: [.stub(installID: installID, deviceID: deviceID, date: baseDate)],
            launches: [.stub(launchID: launchID, installID: installID, startDate: baseDate)],
            sessions: [.stub(sessionID: sessionID, launchID: launchID, startDate: baseDate.addingTimeInterval(50))],
            events: [
                .stub(name: "a", sessionID: sessionID, date: baseDate.addingTimeInterval(100)),
                .stub(name: "b", sessionID: sessionID, date: baseDate.addingTimeInterval(200)),
            ],
            crashes: []
        )
    }
}
