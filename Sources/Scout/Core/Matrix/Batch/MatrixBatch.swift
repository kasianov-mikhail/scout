//
// Copyright 2026 Mikhail Kasianov
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

/// Groups records by hour-of-week and counts them into `GridCell<Int>`.
extension MatrixBatch where Self: DateObject, Cell == GridCell<Int> {
    static func parse(of batch: [Self]) -> [GridCell<Int>] {
        batch.grouped(by: \.hour).mapValues(\.count).map(GridCell.init)
    }
}
