//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

/// A concrete `MetricsObject` that stores a typed scalar `Value`
/// (either `Int` or `Double`) and participates in the sync/matrix
/// pipeline.
///
/// Required by `logMetrics<T: MatrixValue>` so it can construct the right
/// `T.Object` managed-object subclass generically from a scalar value.
///
protocol MetricsValued: MetricsObject & Syncable & MatrixBatch {
    associatedtype Value where Cell.Scalar == Value
    var value: Value { get set }
    init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?)
}

@objc(DoubleMetricsObject)
final class DoubleMetricsObject: MetricsObject, MetricsValued {
    typealias Cell = GridCell<Double>
    @NSManaged var value: Double
}

@objc(IntMetricsObject)
final class IntMetricsObject: MetricsObject, MetricsValued {
    typealias Cell = GridCell<Int>
    @NSManaged var value: Int
}
