//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

protocol CellInitializable {
    associatedtype Value: MatrixValue
    init(key: String, value: Value) throws
}

struct Matrix<T: CellInitializable & Combining> {
    let date: Date
    let name: String
    let recordID: CKRecord.ID
    let cells: [T]
}

extension Matrix: Combining {
    func isDuplicate(of other: Matrix<T>) -> Bool {
        date == other.date && name == other.name
    }

    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }

    static func + (lhs: Self, rhs: Self) -> Self {

        // Ensure the matrices have the same date and name.
        assert(lhs.date == rhs.date, "Dates must match")
        assert(lhs.name == rhs.name, "Names must match")

        return Matrix(
            date: lhs.date,
            name: lhs.name,
            recordID: [lhs.recordID, rhs.recordID].randomElement()!,
            cells: (lhs.cells + rhs.cells).mergeDuplicates()
        )
    }
}

extension Matrix: CustomStringConvertible {
    var description: String {
        "Matrix(\(name), \(date), \(cells.count) cells)"
    }
}
