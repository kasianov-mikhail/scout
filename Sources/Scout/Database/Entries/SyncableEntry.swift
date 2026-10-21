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

    func requeue() {
        for delivery in deliveries {
            delivery.isPending = true
            delivery.attempts = 0
        }
    }
}

typealias DeliverableEntry = SyncableEntry & RecordEncodable

extension SyncableEntry {
    static let deliverableTypes: [any DeliverableEntry.Type] = [
        EventEntry.self,
        ScreenEntry.self,
        ConditionEntry.self,
        SessionEntry.self,
        VisitEntry.self,
        VisitGapEntry.self,
        LaunchEntry.self,
        VersionEntry.self,
        FirstSeenEntry.self,
        RetentionMarkEntry.self,
        InstallEntry.self,
        DeviceEntry.self,
        CrashEntry.self,
        HangEntry.self,
        ResourceEntry.self,
        BacktraceEntry.self,
        DailyMetricEntry.self,
        IntMetricsEntry.self,
        DoubleMetricsEntry.self,
    ]
}
