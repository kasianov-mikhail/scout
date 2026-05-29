//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

@testable import Scout

extension Session {
    @discardableResult static func stub(
        sessionID: UUID = UUID(),
        launchID: UUID? = nil,
        installID: UUID? = nil,
        startDate: Date? = Date(),
        endDate: Date? = nil
    ) -> Session {
        Session(
            startDate: startDate,
            endDate: endDate,
            id: .init(recordName: UUID().uuidString),
            sessionID: sessionID,
            launchID: launchID,
            installID: installID
        )
    }
}
