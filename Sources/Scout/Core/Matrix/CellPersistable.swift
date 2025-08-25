//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

typealias CellPersistable = CellRepresentable & CellInitializable

protocol CellRepresentable {
    associatedtype Value: MatrixValue & CKRecordValueProtocol
    var key: String { get }
    var value: Value { get }
}

protocol CellInitializable {
    associatedtype Value: MatrixValue
    init(key: String, value: Value) throws
}
