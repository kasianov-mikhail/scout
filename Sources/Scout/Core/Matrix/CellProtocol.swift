//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

protocol CellProtocol {
    associatedtype Scalar: MatrixValue & CKRecordValueProtocol

    var key: String { get }
    var value: Scalar { get }

    init(key: String, value: Scalar) throws
}

// Backward compatibility
extension CellProtocol {
    @available(*, deprecated, renamed: "Scalar")
    typealias Value = Scalar
}
