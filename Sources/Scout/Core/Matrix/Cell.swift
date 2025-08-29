//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

struct Cell<T: SyncValue>: Hashable {
    let row: Int
    let column: Int
    let value: T
}

extension Cell: CellProtocol {
    var key: String {
        CellKeyParser.createKey(prefix: "\(row)", suffix: String(format: "%02d", column))
    }

    init(key: String, value: T) {
        let (rowString, columnString) = CellKeyParser.parse(key: key)
        
        guard let row = Int(rowString) else {
            fatalError("Invalid row index")
        }
        guard let column = Int(columnString) else {
            fatalError("Invalid column index")
        }

        self.row = row
        self.column = column
        self.value = value
    }
}

extension Cell: Combining {
    func isDuplicate(of other: Cell<T>) -> Bool {
        row == other.row && column == other.column
    }

    static func + (lhs: Self, rhs: Self) -> Self {
        assert(lhs.row == rhs.row, "Row indices must match")
        assert(lhs.column == rhs.column, "Column indices must match")

        return Cell(
            row: lhs.row,
            column: lhs.column,
            value: lhs.value + rhs.value
        )
    }
}

extension Cell: Comparable {
    static func < (lhs: Cell<T>, rhs: Cell<T>) -> Bool {
        if lhs.row == rhs.row {
            return lhs.column < rhs.column
        } else {
            return lhs.row < rhs.row
        }
    }
}

extension Cell: CustomStringConvertible {
    var description: String {
        "Cell(row: \(row), column: \(column), value: \(value))"
    }
}
