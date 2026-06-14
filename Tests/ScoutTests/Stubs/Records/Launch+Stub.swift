//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

@testable import Scout

extension Launch {
    @discardableResult static func stub(
        launchID: UUID = UUID(),
        installID: UUID? = nil,
        startDate: Date? = Date(),
        endDate: Date? = nil
    ) -> Launch {
        Launch(
            startDate: startDate,
            endDate: endDate,
            id: .init(recordName: UUID().uuidString),
            launchID: launchID,
            installID: installID
        )
    }
}
