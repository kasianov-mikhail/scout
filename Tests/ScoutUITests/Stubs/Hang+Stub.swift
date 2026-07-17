//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

@testable import Scout
@testable import ScoutUI

extension Hang {
    @discardableResult static func stub(
        name: String = "hang",
        fingerprint: String? = nil,
        reason: String? = nil,
        stackTrace: [String] = [],
        duration: TimeInterval = 4,
        deviceID: UUID? = nil,
        sessionID: UUID? = nil,
        launchID: UUID? = nil,
        installID: UUID? = nil,
        date: Date? = Date()
    ) -> Hang {
        Hang(
            name: name,
            fingerprint: fingerprint ?? CrashFingerprint(name: name, reason: reason, stackTrace: stackTrace).value,
            reason: reason,
            stackTrace: stackTrace,
            duration: duration,
            date: date,
            id: UUID().uuidString,
            deviceID: deviceID,
            installID: installID,
            launchID: launchID,
            sessionID: sessionID
        )
    }
}
