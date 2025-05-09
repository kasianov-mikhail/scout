//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

extension Matrix {

    /// An enumeration representing errors that can occur while mapping data.
    enum MapError: LocalizedError {
        case missingDate
        case missingName
        case missingCells

        var errorDescription: String? {
            switch self {
            case .missingDate:
                return "Missing date"
            case .missingName:
                return "Missing name"
            case .missingCells:
                return "Missing cells"
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
    ///   - `MapError.missingDate`: If the record does not contain a valid `date` field.
    ///   - `MapError.missingName`: If the record does not contain a valid `name` field.
    ///   - `MapError.missingCells`: If the record does not contain any cell data.
    ///
    /// - Note: The cell keys are expected to be in the format `cell_<row>_<column>`.
    ///
    init(record: CKRecord) throws {
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

        self.cells = try cellDict.map(U.init)
    }
}
