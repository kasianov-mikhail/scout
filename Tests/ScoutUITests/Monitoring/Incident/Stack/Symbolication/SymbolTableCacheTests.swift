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
        let cache = SymbolTableCache(capacity: 1, missLifetime: 60, now: Date.init)

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
        let cache = SymbolTableCache(capacity: images.count, missLifetime: 60, now: Date.init)

        let first = await cache.tables(uuids: images, database: database)
        database.failing = nil
        let second = await cache.tables(uuids: images, database: database)

        #expect(!first.isEmpty)
        #expect(first[images[0]] == nil)
        #expect(second.count == images.count)
        #expect(database.reads == 3)
    }

    @Test("A missing table is asked for again once its miss expires")
    func missExpiry() async throws {
        let app = UUID()
        let empty = CountingDatabase(records: [], failing: nil)
        let uploaded = CountingDatabase(records: [try makeRecord(image: app)], failing: nil)
        let clock = ManualClock()
        let cache = SymbolTableCache(capacity: 1, missLifetime: 60, now: { clock.now })

        let first = await cache.tables(uuids: [app], database: empty)
        clock.advance(seconds: 59)
        let second = await cache.tables(uuids: [app], database: uploaded)
        clock.advance(seconds: 1)
        let third = await cache.tables(uuids: [app], database: uploaded)

        #expect(first.isEmpty)
        #expect(second.isEmpty)
        #expect(third == [app: makeTable(image: app)])
        #expect(empty.reads == 1)
        #expect(uploaded.reads == 1)
    }

    @Test("The least recently used table is evicted once the cache is full")
    func eviction() async throws {
        let images = (0..<3).map { _ in UUID() }
        let database = CountingDatabase(records: try images.map(makeRecord), failing: nil)
        let cache = SymbolTableCache(capacity: 2, missLifetime: 60, now: Date.init)

        _ = await cache.tables(uuids: [images[0]], database: database)
        _ = await cache.tables(uuids: [images[1]], database: database)
        _ = await cache.tables(uuids: [images[0]], database: database)
        _ = await cache.tables(uuids: [images[2]], database: database)
        let kept = await cache.tables(uuids: [images[0]], database: database)
        let evicted = await cache.tables(uuids: [images[1]], database: database)

        #expect(kept == [images[0]: makeTable(image: images[0])])
        #expect(evicted == [images[1]: makeTable(image: images[1])])
        #expect(database.reads == 4)
    }

    @Test("A request for more tables than the cache holds returns all of them and keeps them for the next identical request")
    func overflow() async throws {
        let images = (0..<6).map { _ in UUID() }
        let database = CountingDatabase(records: try images.map(makeRecord), failing: nil)
        let cache = SymbolTableCache(capacity: 4, missLifetime: 60, now: Date.init)

        let first = await cache.tables(uuids: images, database: database)
        let second = await cache.tables(uuids: images, database: database)

        #expect(first.count == images.count)
        #expect(second.count == images.count)
        #expect(database.reads == 1)
    }

    @Test("Tables kept above the capacity are evicted by a request for other tables")
    func overflowEviction() async throws {
        let images = (0..<4).map { _ in UUID() }
        let database = CountingDatabase(records: try images.map(makeRecord), failing: nil)
        let cache = SymbolTableCache(capacity: 2, missLifetime: 60, now: Date.init)

        _ = await cache.tables(uuids: Array(images[0..<3]), database: database)
        _ = await cache.tables(uuids: [images[3]], database: database)
        let reread = await cache.tables(uuids: Array(images[0..<3]), database: database)

        #expect(reread.count == 3)
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

private final class ManualClock: @unchecked Sendable {
    private let lock = NSLock()
    private var date = Date(timeIntervalSince1970: 0)

    var now: Date {
        lock.withLock { date }
    }

    func advance(seconds: TimeInterval) {
        lock.withLock { date += seconds }
    }
}

private struct MembershipLimitError: Error {}

private struct FailedReadError: Error {}
