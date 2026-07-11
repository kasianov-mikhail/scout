//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

protocol MetricsValued: MetricsEntry {
    associatedtype Value
    var value: Value { get set }
    init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?)
}

@objc(MetricsEntry)
class MetricsEntry: SyncableEntry, HasSession {
    @NSManaged var session: SessionEntry?
    @NSManaged var name: String?
    @NSManaged var telemetry: String?
}

@objc(DoubleMetricsEntry)
final class DoubleMetricsEntry: MetricsEntry, MetricsValued {
    @NSManaged var value: Double
}

@objc(IntMetricsEntry)
final class IntMetricsEntry: MetricsEntry, MetricsValued {
    @NSManaged var value: Int
}
