//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(SyncableEntry)
package class SyncableEntry: DateEntry {
    @NSManaged var deliveries: Set<DeliveryEntry>

    func delivery(for backendID: String) -> DeliveryEntry? {
        deliveries.first { $0.backendID == backendID }
    }
}

extension SyncableEntry {
    // The single registry of concrete entry types delivered during a sync;
    // synchronize() iterates this instead of hardcoding the list at the call
    // site, so a new syncable type is added in one place.
    static let deliverableTypes: [any (SyncableEntry & RecordEncodable).Type] = [
        EventEntry.self,
        SessionEntry.self,
        VisitEntry.self,
        LaunchEntry.self,
        VersionEntry.self,
        InstallEntry.self,
        DeviceEntry.self,
        CrashEntry.self,
        HangEntry.self,
        IntMetricsEntry.self,
        DoubleMetricsEntry.self,
    ]
}
