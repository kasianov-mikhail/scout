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

actor SymbolTableCache {
    static let shared = SymbolTableCache()

    private var tables: [UUID: SymbolTable] = [:]
    private var missing: Set<UUID> = []

    func tables(uuids: [UUID], database: RecordReader) async throws -> [UUID: SymbolTable] {
        let unknown = Set(uuids).subtracting(tables.keys).subtracting(missing)

        let loaded = try await withThrowingTaskGroup(of: LoadedTable.self) { group in
            for uuid in unknown {
                group.addTask {
                    LoadedTable(uuid: uuid, table: try await Self.table(uuid: uuid, database: database))
                }
            }
            return try await group.reduce(into: []) { $0.append($1) }
        }

        for result in loaded {
            if let table = result.table {
                tables[result.uuid] = table
            } else {
                missing.insert(result.uuid)
            }
        }
        return tables.filter { uuids.contains($0.key) }
    }

    private static func table(uuid: UUID, database: RecordReader) async throws -> SymbolTable? {
        do {
            let record = try await database.lookup(recordName: UUID(symbolsFile: uuid).uuidString, fields: ["file"])
            guard let data: Data = record["file"] else {
                return nil
            }
            return try SymbolTable(data: data)
        } catch is RecordNotFoundError {
            return nil
        }
    }
}

private struct LoadedTable: Sendable {
    let uuid: UUID
    let table: SymbolTable?
}
