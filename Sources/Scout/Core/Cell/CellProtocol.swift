//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

protocol CellProtocol: Combining, Sendable {
    associatedtype Scalar: MatrixValue & CKRecordValueProtocol

    var key: String { get }
    var value: Scalar { get }

    init(key: String, value: Scalar) throws
}

extension Array where Element: CellProtocol {
    var summary: String {
        if isEmpty {
            return "[]"
        }
        let items = map { cell in
            "\(cell.key)=\(String(describing: cell.value))"
        }
        return "[\(items.joined(separator: ", "))]"
    }
}
