//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

// MARK: - CellType

/// A protocol that defines the requirements for a cell type used in a matrix.
///
/// Types conforming to this protocol must provide an initializer that can create
/// a cell from a key-value pair.
///
protocol CellType {

    /// The type of the value stored in the cell.
    associatedtype Value

    /// Initializes a cell with a given key and value.
    ///
    /// - Parameters:
    ///   - key: A `String` representing the key of the cell.
    ///   - value: An `Any` type representing the value of the cell.
    /// - Throws: An error if the initialization fails.
    ///
    init(key: String, value: Any) throws
}


// MARK: - Matrix

/// A generic structure representing a matrix of cells.
///
/// This structure encapsulates a collection of cells, each identified by a unique date and name.
/// It conforms to the `Combining` protocol, allowing for the merging of matrices.
///
/// - Parameters:
///  - U: The type of cells in the matrix, which must conform to the `CellType` protocol.
///  - The `Value` type of the cells must conform to the `MatrixType` protocol.
///
struct Matrix<U: CellType & Combining> where U.Value: MatrixType {

    /// The date associated with the matrix.
    let date: Date

    /// The name of the matrix.
    let name: String

    /// The unique record identifier for the matrix.
    let recordID: CKRecord.ID

    /// The collection of cells in the matrix.
    let cells: [U]
}

// MARK: - Combining

extension Matrix: Combining {

    /// Checks if two matrices are duplicates based on their date and name.
    ///
    /// - Parameter other: The matrix to compare against.
    /// - Returns: `true` if the matrices have the same date and name, `false` otherwise.
    ///
    func isDuplicate(of other: Matrix<U>) -> Bool {
        date == other.date && name == other.name
    }

    /// Merges two matrices by combining their cells.
    ///
    /// This operator ensures that the resulting matrix contains only unique cells.
    /// If two cells have the same row and column, their values are added together.
    ///
    /// - Parameters:
    ///   - lhs: The matrix to be updated with the merged values.
    ///   - rhs: The matrix whose values will be merged into `lhs`.
    ///
    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }

    /// Combines two matrices into a new matrix by merging their cells.
    ///
    /// This operator ensures that the resulting matrix contains only unique cells.
    /// If two cells have the same row and column, their values are added together.
    ///
    /// - Parameters:
    ///   - lhs: The first matrix.
    ///   - rhs: The second matrix.
    /// - Returns: A new matrix with merged cells.
    ///
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

// MARK: -

extension Matrix: CustomStringConvertible {

    /// A textual representation of the matrix.
    var description: String {
        "Matrix(\(name), \(date), \(cells.count) cells)"
    }
}
