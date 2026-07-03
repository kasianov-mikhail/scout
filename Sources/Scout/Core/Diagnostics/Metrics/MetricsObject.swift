//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

protocol MetricsValued: MetricsObject {
    associatedtype Value
    var value: Value { get set }
    init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?)
}

@objc(MetricsObject)
class MetricsObject: TrackedObject {
    @NSManaged var name: String?
    @NSManaged var telemetry: String?
}

@objc(DoubleMetricsObject)
final class DoubleMetricsObject: MetricsObject, MetricsValued {
    @NSManaged var value: Double
}

@objc(IntMetricsObject)
final class IntMetricsObject: MetricsObject, MetricsValued {
    @NSManaged var value: Int
}
