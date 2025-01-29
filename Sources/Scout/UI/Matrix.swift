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

// MARK: - Math

extension Matrix<Int> {
    static func += (lhs: inout Self, rhs: Self) {
        lhs = Matrix(
            date: lhs.date,
            name: lhs.name,
            recordID: [lhs.recordID, rhs.recordID].randomElement()!,
            cells: (lhs.cells + rhs.cells).mergeDuplicates()
        )
    }
}

// MARK: - Generic Types

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

// MARK: - CloudKit Mapping

extension Matrix {

    /// An enumeration representing errors that can occur while mapping data.
    enum MapError: LocalizedError {
        case invalidRecord(expected: String, got: String)
        case missingDate
        case missingName
        case missingCells
        case invalidCellFormat
        case incorrectCellType

        var errorDescription: String? {
            switch self {
            case .invalidRecord(let expected, let got):
                return "Invalid record type. Expected \(expected), got \(got)"
            case .missingDate:
                return "Missing date"
            case .missingName:
                return "Missing name"
            case .missingCells:
                return "Missing cells"
            case .invalidCellFormat:
                return "Invalid cell format"
            case .incorrectCellType:
                return "Incorrect cell type"
            }
        }
    }

    /// Initializes a new instance of the conforming type from a given `CKRecord`.
    ///
    /// This initializer attempts to map the provided `CKRecord` to the conforming type,
    /// extracting relevant information and validating the record's structure.
    ///
    /// - Parameter record: The `CKRecord` to initialize the instance from.
    ///
    /// - Throws: An error of type `MapError` if the record is invalid or missing required fields.
    ///   Possible errors include:
    ///   - `MapError.invalidRecord`: If the record type does not match the expected type.
    ///   - `MapError.missingDate`: If the record does not contain a valid `date` field.
    ///   - `MapError.missingName`: If the record does not contain a valid `name` field.
    ///   - `MapError.missingCells`: If the record does not contain any cell data.
    ///   - `MapError.invalidCellFormat`: If the cell keys are not in the expected format.
    ///   - `MapError.incorrectCellType`: If the cell values are not of the expected type.
    ///
    /// - Note: The cell keys are expected to be in the format `cell_<row>_<column>`.
    ///
    init(record: CKRecord) throws {
        guard T.recordName == record.recordType else {
            throw MapError.invalidRecord(expected: T.recordName, got: record.recordType)
        }
        guard let date = record["date"] as? Date else {
            throw MapError.missingDate
        }
        guard let name = record["name"] as? String else {
            throw MapError.missingName
        }

        self.date = date
        self.name = name
        self.recordID = record.recordID

        let cellKeys = record.allKeys().filter { $0.hasPrefix("cell_") }

        guard cellKeys.count > 0 else {
            throw MapError.missingCells
        }

        let cellDict = record.dictionaryWithValues(forKeys: cellKeys)

        self.cells = try cellDict.map { key, value in
            let parts = key.components(separatedBy: "_")

            guard parts.count == 3, let row = Int(parts[1]), let column = Int(parts[2]) else {
                throw MapError.invalidCellFormat
            }

            guard let value = value as? T else {
                throw MapError.incorrectCellType
            }

            return Cell(row: row, column: column, value: value)
        }
    }
}

// MARK: - Removing Duplicates

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

// MARK: -

extension Matrix: CustomStringConvertible {
    var description: String {
        "Matrix(\(name), \(date), \(cells.count) cells)"
    }
}
