//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

@testable import Scout

extension Install {
    @discardableResult static func stub(
        installID: UUID = UUID(),
        deviceID: UUID? = nil,
        date: Date? = Date()
    ) -> Install {
        Install(
            date: date,
            id: UUID().uuidString,
            installID: installID,
            deviceID: deviceID
        )
    }
}
