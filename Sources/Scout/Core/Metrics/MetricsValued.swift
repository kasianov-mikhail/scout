//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

protocol MetricsValued: MetricsObject {
    associatedtype Value: MatrixValue
    var value: Value { get set }
}

@objc(DoubleMetricsObject)
final class DoubleMetricsObject: MetricsObject, MetricsValued, Syncable {
    typealias Cell = GridCell<Double>
    @NSManaged var value: Double
}

@objc(IntMetricsObject)
final class IntMetricsObject: MetricsObject, MetricsValued, Syncable {
    typealias Cell = GridCell<Int>
    @NSManaged var value: Int
}
