//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

protocol MetricScalar: AdditiveArithmetic & Comparable & Hashable & Sendable & RecordValueConvertible {
    associatedtype Object: MetricsValued where Object.Value == Self
    static var seriesValues: String { get }
    init(_ value: Double)
}

extension Int: MetricScalar {
    typealias Object = IntMetricsEntry
    static var seriesValues: String { "int" }
}

extension Double: MetricScalar {
    typealias Object = DoubleMetricsEntry
    static var seriesValues: String { "double" }
}
