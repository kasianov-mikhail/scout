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
import Testing

@testable import ScoutUI

@Suite("SymbolTableCache")
struct SymbolTableCacheTests {
    @Test("Uploaded tables load by image UUID, and missing ones are not asked for again")
    func loading() async throws {
        let app = UUID()
        let system = UUID()
        let table = SymbolTable(uuid: app, functions: [], lines: [], inlines: [])
        var record = Record(recordType: BundledSymbols.fileType, recordID: UUID(symbolsFile: app).uuidString)
        record["file"] = try table.data
        let database = CountingDatabase(records: [record])
        let cache = SymbolTableCache()

        let first = try await cache.tables(uuids: [app, system], database: database)
        let second = try await cache.tables(uuids: [app, system], database: database)

        #expect(first == [app: table])
        #expect(second == [app: table])
        #expect(database.lookups == 2)
    }
}

private final class CountingDatabase: RecordReader, @unchecked Sendable {
    let records: [Record]
    private let lock = NSLock()
    private var count = 0

    var lookups: Int {
        lock.withLock { count }
    }

    init(records: [Record]) {
        self.records = records
    }

    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
        RecordChunk(records: [], cursor: nil)
    }

    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        lock.withLock { count += 1 }
        guard let record = records.first(where: { $0.recordID == recordName }) else {
            throw RecordNotFoundError()
        }
        return record
    }
}
