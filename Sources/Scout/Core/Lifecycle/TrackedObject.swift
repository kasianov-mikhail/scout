//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(TrackedObject)
class TrackedObject: SyncableObject {
    @NSManaged var sessionID: UUID?

    override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(UUID(), forKey: #keyPath(TrackedObject.sessionID))
    }
}
