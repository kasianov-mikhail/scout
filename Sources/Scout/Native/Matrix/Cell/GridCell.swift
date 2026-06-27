//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

typealias GridMatrix<T: MetricScalar> = Matrix<GridCell<T>>

struct GridCell<T: MetricScalar>: Hashable, ChartComposing {
    let row: Int
    let column: Int
    let value: T
}

extension GridCell {
    var secondsSinceBase: Int {
        (row - 1) * Int(TimeInterval.day) + column * Int(TimeInterval.hour)
    }
}

extension GridCell: CellProtocol {
    static var recordType: String { T.recordType }

    var key: String {
        "cell_\(row)_\(column.leadingZero)"
    }

    init(key: String, value: T) throws(CellKeyError) {
        let (rowPart, columnPart) = try key.fields

        guard let row = Int(rowPart) else {
            throw .mismatch(field: "row", value: rowPart)
        }
        guard let column = Int(columnPart) else {
            throw .mismatch(field: "column", value: columnPart)
        }

        self.init(row: row, column: column, value: value)
    }
}

extension GridCell: Combining {
    func isDuplicate(of other: GridCell<T>) -> Bool {
        row == other.row && column == other.column
    }

    static func + (lhs: Self, rhs: Self) -> Self {
        GridCell(
            row: lhs.row,
            column: lhs.column,
            value: lhs.value + rhs.value
        )
    }
}

extension GridCell: Comparable {
    static func < (lhs: GridCell<T>, rhs: GridCell<T>) -> Bool {
        guard lhs.row == rhs.row else {
            return lhs.row < rhs.row
        }
        return lhs.column < rhs.column
    }
}
