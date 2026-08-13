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

    init(name: String, reason: String?, stackTrace: [String], identity: Identity) {
        self.init(
            name: name,
            reason: reason,
            stackTrace: stackTrace,
            date: Date(),
            installID: identity.install,
            launchID: identity.launch,
            sessionID: identity.session.raw,
            appVersion: Bundle.main.marketingVersion
        )
    }

    init(
        name: String, reason: String?, stackTrace: [String], date: Date, installID: UUID, launchID: UUID,
        sessionID: UUID, appVersion: String?
    ) {
        self.name = name
        self.reason = reason
        self.stackTrace = stackTrace
        self.date = date
        self.installID = installID
        self.launchID = launchID
        self.sessionID = sessionID
        self.appVersion = appVersion
    }
}
