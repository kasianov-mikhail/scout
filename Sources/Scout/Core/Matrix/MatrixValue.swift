//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import CloudKit

protocol MatrixValue: CKRecordValueProtocol & AdditiveArithmetic & Sendable & Hashable {
    associatedtype Object: MetricsValued where Object.Value == Self
    static var recordName: String { get }
}

extension Int: MatrixValue {
    typealias Object = IntMetricsObject
    static let recordName = "DateIntMatrix"
}

extension Double: MatrixValue {
    typealias Object = DoubleMetricsObject
    static let recordName = "DateDoubleMatrix"
}
