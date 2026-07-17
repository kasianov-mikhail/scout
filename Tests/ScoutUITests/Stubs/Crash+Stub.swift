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

extension Crash {
    @discardableResult static func stub(
        name: String = "crash",
        fingerprint: String? = nil,
        reason: String? = nil,
        stackTrace: [String] = [],
        deviceID: UUID? = nil,
        sessionID: UUID? = nil,
        launchID: UUID? = nil,
        installID: UUID? = nil,
        date: Date? = Date()
    ) -> Crash {
        Crash(
            name: name,
            fingerprint: fingerprint ?? CrashFingerprint(name: name, reason: reason, stackTrace: stackTrace).value,
            reason: reason,
            stackTrace: stackTrace,
            date: date,
            id: UUID().uuidString,
            deviceID: deviceID,
            installID: installID,
            launchID: launchID,
            sessionID: sessionID
        )
    }
}
