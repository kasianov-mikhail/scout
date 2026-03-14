//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct CrashInfo: Codable {
    let name: String
    let reason: String?
    let stackTrace: [String]
    let date: Date
    let userID: UUID
    let launchID: UUID

    init(name: String, reason: String?, stackTrace: [String]) {
        self.name = name
        self.reason = reason
        self.stackTrace = stackTrace
        self.date = Date()
        self.userID = IDs.user
        self.launchID = IDs.launch
    }
}
