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
    init(record: CKRecord) throws {
        guard let date = record["date"] as? Date else {
            throw MapError.missingField("date")
        }
        guard let name = record["name"] as? String else {
            throw MapError.missingField("name")
        }

        self.recordType = record.recordType
        self.date = date
        self.name = name
        self.record = record
        self.category = record["category"]

        let cellKeys = record.allKeys().filter { $0.hasPrefix("cell_") }
        let cellDict = record.dictionaryWithValues(forKeys: cellKeys)

        guard cellDict.count > 0 else {
            throw MapError.missingCells
        }
        guard let cellDict = cellDict as? [String: T.Scalar] else {
            throw MapError.invalidCells
        }

        self.cells = cellDict.map(T.init)
    }
}

extension Matrix: CKRepresentable {
    var toRecord: CKRecord {
        let record = record ?? CKRecord(recordType: recordType)
        record["date"] = date
        record["name"] = name
        record["category"] = category
        for cell in cells {
            record[cell.key] = cell.value
        }
        return record
    }
}

extension Matrix {
    enum MapError: LocalizedError {
        case missingField(String)
        case missingCells
        case invalidCells

        var errorDescription: String? {
            switch self {
            case .missingField(let field):
                "Missing \(field) field"
            case .missingCells:
                "Missing cells"
            case .invalidCells:
                "Invalid cells. Expected a dictionary of Strings to Int or Double"
            }
        }
    }
}
