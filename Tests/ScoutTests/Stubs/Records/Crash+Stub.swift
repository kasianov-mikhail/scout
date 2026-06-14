//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

@testable import Scout

extension Crash {
    @discardableResult static func stub(
        name: String = "crash",
        sessionID: UUID? = nil,
        launchID: UUID? = nil,
        installID: UUID? = nil,
        date: Date? = Date()
    ) -> Crash {
        Crash(
            name: name,
            reason: nil,
            stackTrace: [],
            date: date,
            id: .init(recordName: UUID().uuidString),
            installID: installID,
            launchID: launchID,
            sessionID: sessionID
        )
    }
}
