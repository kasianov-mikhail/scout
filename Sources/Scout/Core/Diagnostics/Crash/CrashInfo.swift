//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// Snapshot of the identifiers captured at crash time.
///
/// Persisted to disk before the process dies and replayed on the next
/// process start by `logCrash`. The IDs it carries (`installID`,
/// `launchID`, `sessionID`) must be those of the **crashed** process —
/// not the recovery process that eventually inserts the `CrashObject`.
///
struct CrashInfo: Codable {
    let name: String
    let reason: String?
    let stackTrace: [String]
    let date: Date
    let installID: UUID
    let launchID: UUID
    let sessionID: UUID

    init(name: String, reason: String?, stackTrace: [String]) {
        self.name = name
        self.reason = reason
        self.stackTrace = stackTrace
        self.date = Date()
        self.installID = IDs.install
        self.launchID = IDs.launch
        self.sessionID = IDs.session
    }
}
