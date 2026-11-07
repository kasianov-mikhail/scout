//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

@testable import ScoutUI

extension Event {
    @discardableResult static func stub(name: String = "event", level: EventLevel? = nil, sessionID: UUID? = nil, installID: UUID? = nil, deviceID: UUID? = nil, date: Date? = Date()) -> Event {
        Event(
            name: name,
            level: level,
            date: date,
            paramCount: nil,
            uuid: nil,
            id: UUID().uuidString,
            installID: installID,
            sessionID: sessionID,
            deviceID: deviceID
        )
    }
}
