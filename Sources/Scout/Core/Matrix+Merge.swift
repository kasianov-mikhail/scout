//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension [Matrix<Int>] {

    /// Merges duplicate elements in the array based on the `date` and `name` properties.
    /// If duplicates are found, they are combined using the `+=` operator.
    ///
    func mergeDuplicates() -> Self {
        reduce(into: []) { result, matrix in
            if let index = result.firstIndex(where: {
                $0.date == matrix.date && $0.name == matrix.name
            }) {
                result[index] += matrix
            } else {
                result.append(matrix)
            }
        }
    }
}

extension [Cell<Int>] {

    /// Merges duplicate cells in the matrix by summing their values.
    ///
    /// This function iterates through the cells in the matrix and combines cells that have the
    /// same row and column by adding their values together. The resulting matrix will have unique
    /// cells with summed values.
    ///
    func mergeDuplicates() -> Self {
        reduce(into: []) { result, cell in
            if let index = result.firstIndex(where: {
                $0.row == cell.row && $0.column == cell.column
            }) {
                result[index] += cell
            } else {
                result.append(cell)
            }
        }
    }
}
