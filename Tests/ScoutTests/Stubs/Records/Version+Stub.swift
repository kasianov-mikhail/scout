//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

@testable import Scout

extension Version {
    @discardableResult static func stub(
        appVersion: String? = "1.0",
        buildNumber: String? = "1",
        launchID: UUID? = nil,
        date: Date? = Date()
    ) -> Version {
        Version(
            appVersion: appVersion,
            buildNumber: buildNumber,
            launchID: launchID,
            date: date,
            id: UUID().uuidString
        )
    }
}
