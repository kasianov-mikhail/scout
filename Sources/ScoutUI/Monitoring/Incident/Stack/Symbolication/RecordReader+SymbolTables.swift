//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//
import Foundation
import Scout
import SymbolTable

extension RecordReader {
    func symbolTables(uuids: [UUID]) async throws -> [UUID: SymbolTable] {
        let images = Dictionary(uniqueKeysWithValues: uuids.map { (UUID(symbolsFile: $0).uuidString, $0) })
        var tables: [UUID: SymbolTable] = [:]

        let records = try await readAll(
            type: SymbolsFileRecord.self,
            field: "uuid",
            values: Array(images.keys),
            fields: SymbolsFileRecord.desiredKeys
        )

        for record in records {
            guard let image = images[record.recordID] else {
                continue
            }
            do {
                tables[image] = try SymbolTable(data: SymbolsFileRecord(record: record).file)
            } catch {
                print("Failed to decode symbol table \(record.recordID): \(error)")
            }
        }

        return tables
    }
}

private struct SymbolsFileRecord: RecordDecodable {
    static let recordType = BundledSymbols.fileType
    static let desiredKeys = ["file"]

    let id: String
    let file: Data

    init(record: Record) throws {
        guard let file: Data = record["file"] else {
            throw IncompleteSymbolsFileError(recordID: record.recordID)
        }
        self.id = record.recordID
        self.file = file
    }

    var record: Record {
        var record = Record(recordType: Self.recordType, recordID: id)
        record["file"] = file
        return record
    }
}

private struct IncompleteSymbolsFileError: Error {
    let recordID: String
}
