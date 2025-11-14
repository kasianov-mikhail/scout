//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

protocol MatrixBatch {
    associatedtype Cell: CellProtocol
    static func matrix(of batch: [Self]) throws(MatrixPropertyError) -> Matrix<Cell>
}

struct MatrixPropertyError: LocalizedError {
    let errorDescription: String?

    init(_ property: String) {
        errorDescription = "Missing property: \(property). Cannot group objects."
    }
}
