//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct GridCell<T: MatrixValue>: Hashable {
    let row: Int
    let column: Int
    let value: T
}

// MARK: - Matrix

typealias GridMatrix<T: MatrixValue> = Matrix<GridCell<T>>

extension GridCell: CellProtocol {
    var key: String {
        "cell_\(row)_\(column.leadingZero)"
    }

    init(key: String, value: T) throws {
        let parts = key.components(separatedBy: "_")

        guard parts.count == 3 else {
            throw CellKeyError.malformed(key)
        }
        guard let row = Int(parts[1]) else {
            throw CellKeyError.invalidComponent(field: "row", value: parts[1])
        }
        guard let column = Int(parts[2]) else {
            throw CellKeyError.invalidComponent(field: "column", value: parts[2])
        }

        self.init(row: row, column: column, value: value)
    }
}

// MARK: - Combining

extension GridCell: Combining {
    var duplicateKey: String {
        key
    }

    static func + (lhs: Self, rhs: Self) -> Self {
        GridCell(
            row: lhs.row,
            column: lhs.column,
            value: lhs.value + rhs.value
        )
    }
}

// MARK: -

extension GridCell: Comparable {
    static func < (lhs: GridCell<T>, rhs: GridCell<T>) -> Bool {
        guard lhs.row == rhs.row else {
            return lhs.row < rhs.row
        }
        return lhs.column < rhs.column
    }
}

extension GridCell: CustomStringConvertible {
    var description: String {
        "Cell(row: \(row), column: \(column), value: \(value))"
    }
}
