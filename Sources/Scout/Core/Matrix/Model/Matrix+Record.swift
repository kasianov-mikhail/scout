//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Matrix: RecordDecodable {
    init(record: Record) throws {
        guard let date: Date = record["date"] else { throw MapError.missingField("date") }
        guard let name: String = record["name"] else { throw MapError.missingField("name") }

        self.recordType = record.recordType
        self.date = date
        self.name = name
        self.record = record
        self.category = record["category"]

        let cells = try record.fields
            .filter { $0.key.hasPrefix("cell_") }
            .map { key, value -> T in
                guard let scalar = T.Scalar(recordValue: value) else {
                    throw MapError.invalidCells
                }
                return try T(key: key, value: scalar)
            }

        guard cells.count > 0 else {
            throw MapError.missingCells
        }

        self.cells = cells
    }
}

extension Matrix: RecordRepresentable {
    var toRecord: Record {
        var record = record ?? Record(recordType: recordType, id: RecordID(recordName: UUID().uuidString))
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
