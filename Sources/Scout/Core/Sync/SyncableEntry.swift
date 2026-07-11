//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(SyncableEntry)
class SyncableEntry: DateEntry {
    @NSManaged var deliveries: Set<DeliveryEntry>

    func delivery(for backendID: String) -> DeliveryEntry? {
        deliveries.first { $0.backendID == backendID }
    }
}
