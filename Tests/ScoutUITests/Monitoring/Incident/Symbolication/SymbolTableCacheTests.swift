//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//
import ConnectorSupport
import Foundation
import Scout
import SymbolTable
import Testing

@testable import ScoutUI

@Suite("SymbolTableCache")
struct SymbolTableCacheTests {
    @Test("Tables load in one read per 250 images, and missing ones are not asked for again")
    func loading() async throws {
        let app = UUID()
        let system = (0..<599).map { _ in UUID() }
        let database = CountingDatabase(records: [try makeRecord(image: app)], failing: nil)
        let cache = SymbolTableCache()

        let first = await cache.tables(uuids: [app] + system, database: database)
        let second = await cache.tables(uuids: [app] + system, database: database)

        #expect(first == [app: makeTable(image: app)])
        #expect(second == [app: makeTable(image: app)])
        #expect(database.reads == 3)
    }

    @Test("A failed read keeps the tables of the other reads, and its images are asked for again")
    func failedRead() async throws {
        let images = (0..<300).map { _ in UUID() }
        let database = CountingDatabase(records: try images.map(makeRecord), failing: images[0])
        let cache = SymbolTableCache()

        let first = await cache.tables(uuids: images, database: database)
        database.failing = nil
        let second = await cache.tables(uuids: images, database: database)

        #expect(!first.isEmpty)
        #expect(first[images[0]] == nil)
        #expect(second.count == images.count)
        #expect(database.reads == 3)
    }

    private func makeTable(image: UUID) -> SymbolTable {
        SymbolTable(uuid: image, functions: [], lines: [], inlines: [])
    }

    private func makeRecord(image: UUID) throws -> Record {
        let id = UUID(symbolsFile: image).uuidString
        var record = Record(recordType: BundledSymbols.fileType, recordID: id)
        record["uuid"] = id
        record["file"] = try makeTable(image: image).data
        return record
    }
}

private final class CountingDatabase: RecordReader, @unchecked Sendable {
    let records: [Record]
    private let lock = NSLock()
    private var count = 0
    private var failingImage: UUID?

    var reads: Int {
        lock.withLock { count }
    }

    var failing: UUID? {
        get { lock.withLock { failingImage } }
        set { lock.withLock { failingImage = newValue } }
    }

    init(records: [Record], failing: UUID?) {
        self.records = records
        self.failingImage = failing
    }

    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
        lock.withLock { count += 1 }
        guard case .strings(let values) = query.filters.first?.value else {
            throw MembershipLimitError()
        }
        guard values.count <= 250 else {
            throw MembershipLimitError()
        }
        if let failing, values.contains(UUID(symbolsFile: failing).uuidString) {
            throw FailedReadError()
        }
        return RecordChunk(records: records.matching(query), cursor: nil)
    }

    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        Issue.record("Symbol tables must load by membership reads")
        throw RecordNotFoundError()
    }
}

private struct MembershipLimitError: Error {}

private struct FailedReadError: Error {}
