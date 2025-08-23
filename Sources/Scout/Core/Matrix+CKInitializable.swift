//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

protocol CKInitializable {
    init(record: CKRecord) throws
}

extension Matrix: CKInitializable {
    enum MapError: LocalizedError {
        case missingDate
        case missingName
        case missingCells
        case invalidCells

        var errorDescription: String? {
            switch self {
            case .missingDate:
                "Missing date field"
            case .missingName:
                "Missing name field"
            case .missingCells:
                "Missing cells"
            case .invalidCells:
                "Invalid cells. Expected a dictionary of Strings to Int or Double"
            }
        }
    }

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
        let cellDict = record.dictionaryWithValues(forKeys: cellKeys)

        guard cellDict.count > 0 else {
            throw MapError.missingCells
        }
        guard let cellDict = cellDict as? [String: T.Value] else {
            throw MapError.invalidCells
        }

        self.cells = try cellDict.map(T.init)
    }
}
