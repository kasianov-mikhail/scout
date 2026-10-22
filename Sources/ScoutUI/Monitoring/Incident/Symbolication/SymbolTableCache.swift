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

    func tables(uuids: [UUID], database: RecordReader) async -> [UUID: SymbolTable] {
        let unknown = Array(Set(uuids).subtracting(tables.keys).subtracting(missing))

        let loaded = await unknown.readInMembershipChunks { chunk in
            LoadedTables(requested: chunk, found: try await database.symbolTables(uuids: chunk))
        }

        for result in loaded {
            switch result {
            case .success(let result):
                tables.merge(result.found) { $1 }
                missing.formUnion(Set(result.requested).subtracting(result.found.keys))
            case .failure(let error):
                print("Failed to load symbol tables: \(error)")
            }
        }
        return tables.filter { uuids.contains($0.key) }
    }
}

private struct LoadedTables: Sendable {
    let requested: [UUID]
    let found: [UUID: SymbolTable]
}
