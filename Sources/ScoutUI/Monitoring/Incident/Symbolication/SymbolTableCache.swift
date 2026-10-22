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

private let membershipLimit = 250

actor SymbolTableCache {
    static let shared = SymbolTableCache()

    private var tables: [UUID: SymbolTable] = [:]
    private var missing: Set<UUID> = []

    func tables(uuids: [UUID], database: RecordReader) async -> [UUID: SymbolTable] {
        let unknown = Array(Set(uuids).subtracting(tables.keys).subtracting(missing))

        let loaded = await withTaskGroup(of: LoadedTables.self) { group in
            for start in stride(from: 0, to: unknown.count, by: membershipLimit) {
                let chunk = Array(unknown[start..<min(start + membershipLimit, unknown.count)])
                group.addTask {
                    do {
                        return LoadedTables(requested: chunk, found: try await database.symbolTables(uuids: chunk))
                    } catch {
                        print("Failed to load symbol tables: \(error)")
                        return LoadedTables(requested: [], found: [:])
                    }
                }
            }
            return await group.reduce(into: []) { $0.append($1) }
        }

        for result in loaded {
            tables.merge(result.found) { $1 }
            missing.formUnion(Set(result.requested).subtracting(result.found.keys))
        }
        return tables.filter { uuids.contains($0.key) }
    }
}

private struct LoadedTables: Sendable {
    let requested: [UUID]
    let found: [UUID: SymbolTable]
}
