//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

/// A generic structure representing a matrix of elements conforming to the `MatrixType` protocol.
/// This structure provides functionality to work with matrices of various types, ensuring that
/// the elements conform to the required operations defined in the `MatrixType` protocol.
///
/// - Note: The elements of the matrix must conform to the `MatrixType` protocol.
///
/// - Parameters:
///   - T: The type of elements in the matrix, which must conform to the `MatrixType` protocol.
///
struct Matrix<T: MatrixType>: Equatable {
    let date: Date
    let name: String
    let recordID: CKRecord.ID
    let cells: [Cell<T>]
}

// MARK: - Maths

extension Matrix<Int> {

    /// Adds two matrices together, merging duplicate cells.
    ///
    /// This operator adds two matrices together, ensuring that the resulting matrix
    /// contains only unique cells. If two cells have the same row and column, the
    /// values are added together.
    ///
    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }

    /// Adds two matrices together, merging duplicate cells.
    ///
    /// This operator adds two matrices together, ensuring that the resulting matrix
    /// contains only unique cells. If two cells have the same row and column, the
    /// values are added together.
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

// MARK: - Matrix Type

/// A protocol that defines the requirements for a matrix type.
///
/// Conforming types must provide a static `recordName` property that specifies the
/// name of the CloudKit record type used to store the matrix data.
///
protocol MatrixType: CellValue {
    static var recordName: String { get }
}

extension Int: MatrixType {
    static let recordName = "DateIntMatrix"
}

// MARK: -

extension Matrix: CustomStringConvertible {
    var description: String {
        "Matrix(\(name), \(date), \(cells.count) cells)"
    }
}
