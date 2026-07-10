//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct HangInfo: Codable {
    let name: String
    let reason: String?
    let stackTrace: [String]
    let duration: TimeInterval
    let date: Date
    let installID: UUID
    let launchID: UUID
    let sessionID: UUID
    let appVersion: String?

    init(name: String, reason: String?, stackTrace: [String], duration: TimeInterval, sessionID: UUID = GlobalIdentity.live.session.raw) {
        self.name = name
        self.reason = reason
        self.stackTrace = stackTrace
        self.duration = duration
        self.date = Date()
        self.installID = GlobalIdentity.live.install
        self.launchID = GlobalIdentity.live.launch
        self.sessionID = sessionID
        self.appVersion = Bundle.main.marketingVersion
    }
}
