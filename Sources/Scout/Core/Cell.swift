//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// A structure representing a cell in a matrix, identified by its row and column indices,
/// and containing a value of a generic type.
///
/// - Generic Parameter T: The type of the value stored in the cell.
///
struct Cell<T: Hashable>: Hashable {

    /// The row index of the cell.
    let row: Int

    /// The column index of the cell.
    let column: Int

    /// The value stored in the cell.
    let value: T
}

// MARK: - CellType

extension Cell: CellType {
    typealias Value = T

    init(key: String, value: Any) {
        let parts = key.components(separatedBy: "_")

        guard parts.count == 3 else {
            fatalError("Invalid key format")
        }

        guard let row = Int(parts[1]) else {
            fatalError("Invalid row index")
        }

        guard let column = Int(parts[2]) else {
            fatalError("Invalid column index")
        }

        guard let value = value as? T else {
            fatalError("Invalid value type")
        }

        self.row = row
        self.column = column
        self.value = value
    }
}

// MARK: - Combining

extension Cell: Combining where T: AdditiveArithmetic {

    /// Checks if the current cell is a duplicate of another cell.
    func isDuplicate(of other: Cell<T>) -> Bool {
        row == other.row && column == other.column
    }

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

// MARK: -

extension Cell: CustomStringConvertible {

    /// A string representation of the cell.
    var description: String {
        "Cell(\(row), \(column), \(value)) of type \(T.self)"
    }
}
