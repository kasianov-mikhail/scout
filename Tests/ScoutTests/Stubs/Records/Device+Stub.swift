//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

@testable import Scout

extension Device {
    @discardableResult static func stub(
        deviceID: UUID = UUID(),
        date: Date? = Date()
    ) -> Device {
        Device(
            date: date,
            id: UUID().uuidString,
            deviceID: deviceID
        )
    }
}
