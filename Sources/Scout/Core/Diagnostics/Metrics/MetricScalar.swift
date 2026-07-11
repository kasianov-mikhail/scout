//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

protocol MetricScalar: AdditiveArithmetic & Comparable & Hashable & Sendable & RecordValueConvertible {
    associatedtype Object: MetricsValued where Object.Value == Self
    static var recordType: String { get }
}

extension Int: MetricScalar {
    typealias Object = IntMetricsEntry
    static let recordType = "DateIntMatrix"
}

extension Double: MetricScalar {
    typealias Object = DoubleMetricsEntry
    static let recordType = "DateDoubleMatrix"
}
