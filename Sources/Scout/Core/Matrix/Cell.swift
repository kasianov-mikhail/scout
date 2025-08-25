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

extension Cell: CellPersistable {
    var key: String {
        "cell_\(row)_\(String(format: "%02d", column))"
    }

    init(key: String, value: T) {
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

extension Cell: CustomStringConvertible {
    var description: String {
        "Cell(\(row), \(column), \(value)) of type \(T.self)"
    }
}
