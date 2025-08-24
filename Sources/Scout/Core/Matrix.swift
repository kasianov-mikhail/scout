//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

protocol CellRepresentable {
    associatedtype Value: MatrixValue & CKRecordValueProtocol
    var key: String { get }
    var value: Value { get }
}

protocol CellInitializable {
    associatedtype Value: MatrixValue
    init(key: String, value: Value) throws
}

typealias CellPersistable = CellRepresentable & CellInitializable

struct Matrix<T: CellPersistable & Combining & Sendable> {
    let date: Date
    let name: String
    let recordID: CKRecord.ID?
    let cells: [T]
}

extension Matrix: Combining {
    func isDuplicate(of other: Matrix<T>) -> Bool {
        date == other.date && name == other.name
    }

    static func + (lhs: Self, rhs: Self) -> Self {
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

extension Matrix: CKRepresentable {
    var toRecord: CKRecord {
        let record = CKRecord(recordType: "DateIntMatrix")
        record["date"] = date
        record["name"] = name
        for cell in cells {
            record[cell.key] = cell.value
        }
        return record
    }
}

extension Matrix: CustomStringConvertible {
    var description: String {
        "Matrix(\(name), \(date), \(cells.count) cells)"
    }
}
