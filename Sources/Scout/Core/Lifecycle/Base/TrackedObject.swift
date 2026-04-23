//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

/// `SyncableObject` that adds a per-record `sessionID`, for items that
/// are logged inside a user session (events, crashes, metrics, activity,
/// and `SessionObject` itself).
///
/// Lifecycle records that aren't session-scoped (`DeviceObject`,
/// `InstallObject`, `LaunchObject`, `VersionObject`) sit on
/// `SyncableObject` directly.
///
@objc(TrackedObject)
class TrackedObject: SyncableObject {
    @NSManaged var sessionID: UUID

    override func awakeFromInsert() {
        super.awakeFromInsert()
        sessionID = IDs.session
    }
}
