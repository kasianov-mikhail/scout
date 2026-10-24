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
    static let shared = SymbolTableCache(capacity: 4, missLifetime: 300, now: Date.init)

    private let capacity: Int
    private let missLifetime: TimeInterval
    private let now: @Sendable () -> Date
    private var tables: [UUID: SymbolTable] = [:]
    private var recent: [UUID] = []
    private var missing: [UUID: Date] = [:]

    init(capacity: Int, missLifetime: TimeInterval, now: @escaping @Sendable () -> Date) {
        self.capacity = capacity
        self.missLifetime = missLifetime
        self.now = now
    }

    func tables(uuids: [UUID], database: RecordReader) async -> [UUID: SymbolTable] {
        let requested = Set(uuids)
        let date = now()
        missing = missing.filter { $0.value > date }

        var found = tables.filter { requested.contains($0.key) }
        let unknown = Array(requested.subtracting(found.keys).subtracting(missing.keys))

        let loaded = await unknown.readInMembershipChunks { chunk in
            LoadedTables(requested: chunk, found: try await database.symbolTables(uuids: chunk))
        }

        let expiry = now().addingTimeInterval(missLifetime)
        for result in loaded {
            switch result {
            case .success(let result):
                found.merge(result.found) { $1 }
                for uuid in Set(result.requested).subtracting(result.found.keys) {
                    missing[uuid] = expiry
                }
            case .failure(let error):
                print("Failed to load symbol tables: \(error)")
            }
        }

        tables.merge(found) { $1 }
        recent = recent.filter { found[$0] == nil } + found.keys
        while recent.count > max(capacity, found.count) {
            tables[recent.removeFirst()] = nil
        }
        return found
    }
}

private struct LoadedTables: Sendable {
    let requested: [UUID]
    let found: [UUID: SymbolTable]
}
