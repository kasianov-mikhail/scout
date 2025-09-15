//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

protocol MetricsValued: Syncable {
    associatedtype Value: MatrixValue where Cell == GridCell<Value>
    var value: Value { get set }
}

@objc(DoubleMetricsObject)
final class DoubleMetricsObject: MetricsObject, MetricsValued {
    @NSManaged var value: Double
}

@objc(IntMetricsObject)
final class IntMetricsObject: MetricsObject, MetricsValued {
    @NSManaged var value: Int
}
