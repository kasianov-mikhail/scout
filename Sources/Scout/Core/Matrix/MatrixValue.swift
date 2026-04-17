//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData

protocol RecordTyped {
    static var recordType: String { get }
}

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
