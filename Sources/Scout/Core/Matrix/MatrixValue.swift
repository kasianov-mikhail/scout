//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData

/// A scalar type that can live in a matrix cell — currently `Int` and
/// `Double`.
///
/// Carries its own CloudKit `recordType` (e.g. `"DateIntMatrix"`) and a
/// back-reference to the `MetricsObject` subclass that stores it
/// (`IntMetricsObject` / `DoubleMetricsObject`). The back-reference lets
/// `logMetrics<T: MatrixValue>` construct the right managed-object
/// subclass generically.
///
protocol MatrixValue: RecordTyped & AdditiveArithmetic & Comparable & Hashable & Sendable & CKRecordValueProtocol {
    associatedtype Object: MetricsValued where Object.Value == Self
}

extension Int: MatrixValue {
    typealias Object = IntMetricsObject
    static let recordType = "DateIntMatrix"
}

extension Double: MatrixValue {
    typealias Object = DoubleMetricsObject
    static let recordType = "DateDoubleMatrix"
}
