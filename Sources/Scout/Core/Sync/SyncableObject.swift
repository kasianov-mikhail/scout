//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(SyncableObject)
class SyncableObject: DateObject {
    class var isLocalOnly: Bool { false }

    @NSManaged var deliveries: Set<SyncDelivery>

    func delivery(for backendID: String) -> SyncDelivery? {
        deliveries.first { $0.backendID == backendID }
    }
}
