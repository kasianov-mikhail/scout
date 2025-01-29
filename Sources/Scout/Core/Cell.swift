//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// A typealias that combines the `Equatable`, `Hashable`, and `AdditiveArithmetic` protocols.
/// This typealias is used to define the requirements for the value type of a `Cell`.
///
typealias CellValue = Equatable & Hashable & AdditiveArithmetic

/// A structure representing a cell in a matrix.
///
/// The `Cell` structure is generic over a type `T` that conforms to the `CellValue` typealias.
/// It includes properties for the row and column indices of the cell, as well as the value of the cell.
///
/// - Parameters:
///   - T: The type of the value in the cell, which must conform to the `CellValue` typealias.
///
struct Cell<T: CellValue>: Equatable, Hashable {
    let row: Int
    let column: Int
    let value: T
}

// MARK: - Maths

extension Cell {

    /// Adds the values of two cells and assigns the result to the left-hand side cell.
    ///
    /// This operator adds the values of two cells that have the same row and column indices.
    /// The result is assigned to the left-hand side cell.
    ///
    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }

    /// Adds the values of two cells and returns the result as a new cell.
    ///
    /// This operator adds the values of two cells that have the same row and column indices.
    /// The result is returned as a new cell.
    ///
    static func + (lhs: Self, rhs: Self) -> Self {

        // Ensure that the row and column indices match
        assert(lhs.row == rhs.row, "Row indices must match")
        assert(lhs.column == rhs.column, "Column indices must match")

        return Cell(
            row: lhs.row,
            column: lhs.column,
            value: lhs.value + rhs.value
        )
    }
}

// MARK: - CustomStringConvertible

extension Cell: CustomStringConvertible {
    var description: String {
        "Cell(\(row), \(column), \(value)) of type \(T.self)"
    }
}
