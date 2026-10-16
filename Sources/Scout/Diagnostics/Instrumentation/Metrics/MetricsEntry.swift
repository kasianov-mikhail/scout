//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

package protocol MetricsValued: MetricsEntry {
    associatedtype Value
    var value: Value { get set }
    init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?)
}

@objc(MetricsEntry)
package class MetricsEntry: SyncableEntry, HasSession {
    @NSManaged var session: SessionEntry?
    @NSManaged var name: String?
    @NSManaged var telemetry: String?
}

@objc(DoubleMetricsEntry)
package final class DoubleMetricsEntry: MetricsEntry, MetricsValued {
    @NSManaged package var value: Double
}

@objc(IntMetricsEntry)
package final class IntMetricsEntry: MetricsEntry, MetricsValued {
    @NSManaged package var value: Int
}
