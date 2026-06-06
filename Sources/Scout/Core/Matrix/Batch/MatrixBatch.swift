//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// A group of records that can be reduced into a single `Matrix`.
///
/// Conformers decide how their batch maps to cells via `matrix(of:)`.
/// For the common "count records by hour-of-week" case see the default
/// `parse(of:)` below; for lifecycle records see `GridBatch`.
///
protocol MatrixBatch {
    associatedtype Cell: CellProtocol
    static func matrix(of batch: [Self]) throws -> Matrix<Cell>
}

/// Thrown when a batch is missing a property required to form a matrix
/// (e.g. no `week` on the seed record).
///
struct MatrixPropertyError: LocalizedError {
    let errorDescription: String?

    init(_ property: String) {
        errorDescription = "Missing property: \(property). Cannot group objects."
    }
}

/// Groups records by hour-of-week and counts them into `GridCell<Int>`.
extension MatrixBatch where Self: DateObject, Cell == GridCell<Int> {
    static func parse(of batch: [Self]) throws -> [GridCell<Int>] {
        try batch.grouped(by: \.hour).mapValues(\.count).map(GridCell.init)
    }
}
