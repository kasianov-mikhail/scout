//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

package protocol MetricScalar: AdditiveArithmetic & Comparable & Hashable & Sendable & RecordValueConvertible {
    associatedtype Object: MetricsValued where Object.Value == Self
    static var seriesValues: String { get }
    init(_ value: Double)
}

extension Int: MetricScalar {
    package typealias Object = IntMetricsEntry
    static package var seriesValues: String { "int" }
}

extension Double: MetricScalar {
    package typealias Object = DoubleMetricsEntry
    static package var seriesValues: String { "double" }
}
