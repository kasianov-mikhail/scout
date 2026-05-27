//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

@testable import Scout

extension Event {
    @discardableResult static func stub(
        name: String = "event",
        sessionID: UUID? = nil,
        installID: UUID? = nil,
        date: Date? = Date()
    ) -> Event {
        Event(
            name: name,
            level: nil,
            date: date,
            paramCount: nil,
            uuid: nil,
            id: .init(recordName: UUID().uuidString),
            installID: installID,
            sessionID: sessionID
        )
    }
}
