//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

@objc(IDObject)
class IDObject: DateObject {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(UUID(), forKey: #keyPath(IDObject.sessionID))
        setPrimitiveValue(IDs.user, forKey: #keyPath(IDObject.userID))
        setPrimitiveValue(IDs.launch, forKey: #keyPath(IDObject.launchID))
    }
}
