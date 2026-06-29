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
    let installID: UUID
    let launchID: UUID
    let sessionID: UUID
    let appVersion: String?

    init(name: String, reason: String?, stackTrace: [String], sessionID: UUID = IDs.session) {
        self.name = name
        self.reason = reason
        self.stackTrace = stackTrace
        self.date = Date()
        self.installID = IDs.install
        self.launchID = IDs.launch
        self.sessionID = sessionID
        self.appVersion = Bundle.main.marketingVersion
    }
}
