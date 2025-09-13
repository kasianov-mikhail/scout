//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

struct Matrix<T: CellProtocol & Combining & Sendable> {
    let recordType: String
    let date: Date
    let name: String
    let category: String?
    let recordID: CKRecord.ID
    let cells: [T]

    func lookupExisting(in database: Database) async throws -> Self? {
        let name = NSPredicate(format: "name == %@", name)
        let date = NSPredicate(format: "date == %@", date as NSDate)
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [name, date])
        let query = CKQuery(recordType: recordType, predicate: predicate)

        let matrices = try await database.allRecords(matching: query, desiredKeys: nil)
        let matrix = try matrices.randomElement().map(Matrix.init(record:))

        return matrix
    }
}

extension Matrix: Combining {
    func isDuplicate(of other: Matrix<T>) -> Bool {
        return date == other.date
            && name == other.name
            && category == other.category
            && recordType == other.recordType
    }

    static func + (lhs: Self, rhs: Self) -> Self {
        Matrix(
            recordType: lhs.recordType,
            date: lhs.date,
            name: lhs.name,
            category: lhs.category,
            recordID: [lhs.recordID, rhs.recordID].randomElement()!,
            cells: (lhs.cells + rhs.cells).mergeDuplicates()
        )
    }
}

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
        self.category = record["category"]
        self.recordID = record.recordID

        let cellKeys = record.allKeys().filter { $0.hasPrefix("cell_") }
        let cellDict = record.dictionaryWithValues(forKeys: cellKeys)

        guard cellDict.count > 0 else {
            throw MapError.missingCells
        }
        guard let cellDict = cellDict as? [String: T.Scalar] else {
            throw MapError.invalidCells
        }

        self.cells = try cellDict.map(T.init)
    }
}

extension Matrix: CKRepresentable {
    var toRecord: CKRecord {
        let record = CKRecord(recordType: recordType, recordID: recordID)
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
