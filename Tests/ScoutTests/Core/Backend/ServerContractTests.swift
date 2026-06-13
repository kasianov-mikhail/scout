//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import Foundation
import Testing

@testable import Scout

/// The live server under test, supplied by the Server workflow.
private let serverURL = ProcessInfo.processInfo.environment["SCOUT_SERVER_URL"].flatMap(URL.init(string:))

/// A fixed timestamp all contract records carry, so date equality is
/// asserted against a known constant rather than a record round trip.
private let eventDate = Date(timeIntervalSince1970: 1_750_000_000)

/// Fixed `params` bytes every contract record carries, so the `bytes` wire
/// coding (base64) is exercised end to end and not just in unit tests.
private let eventParams = Data([0x00, 0x01, 0xFE, 0xFF])

/// End-to-end checks against a live Scout server.
///
/// The HTTP wire format (`HTTPQueryCoding`/`HTTPRecordCoding`) is a contract
/// shared with the `scout-server` repository, and unit tests can only verify
/// Scout's side of it. These tests exercise `HTTPDatabase` against a running
/// server instead: they are skipped unless `SCOUT_SERVER_URL` points at one,
/// which the Server workflow arranges in CI.
///
@Suite("Scout server contract", .enabled(if: serverURL != nil))
struct ServerContractTests {
    @Test("A written record can be looked up by name")
    func writeAndLookup() async throws {
        let database = try makeDatabase()
        let record = makeEvent(name: "login", index: 1)

        try await database.write(record: record)
        let restored = try await database.lookup(id: record.recordID, fields: nil)

        #expect(restored.recordType == "Event")
        #expect(restored.recordID.recordName == record.recordID.recordName)
        #expect(restored["name"] == "login")
        #expect(restored["param_count"] == Int64(1))
        #expect(restored["date"] == eventDate)
        #expect(restored["params"] == eventParams)
    }

    @Test("Lookup honors the requested field list")
    func lookupProjection() async throws {
        let database = try makeDatabase()
        let record = makeEvent(name: "login", index: 1)

        try await database.write(record: record)
        let restored = try await database.lookup(id: record.recordID, fields: ["name"])

        #expect(restored["name"] == "login")
        #expect(restored["param_count"] == nil)
    }

    @Test("Queries filter and sort on the server")
    func queryFilterAndSort() async throws {
        let database = try makeDatabase()
        let marker = UUID().uuidString
        try await database.write(records: (0..<3).reversed().map { makeEvent(name: marker, index: $0) })

        let chunk = try await database.read(matching: makeQuery(marker: marker), fields: nil)

        #expect(paramCounts(in: chunk.records) == [0, 1, 2])
        #expect(chunk.cursor == nil)
    }

    @Test("Cursors page through a result set larger than the limit")
    func pagination() async throws {
        let database = try makeDatabase()
        let marker = UUID().uuidString
        try await database.write(records: (0..<5).map { makeEvent(name: marker, index: $0) })

        var chunk = try await database.read(matching: makeQuery(marker: marker), fields: nil, limit: 2)
        var indices = paramCounts(in: chunk.records)
        #expect(indices.count == 2)

        // Bounded so a server that never stops handing back a cursor fails the
        // assertion below rather than looping until the job's CI timeout.
        for _ in 0..<10 {
            guard let cursor = chunk.cursor else { break }
            chunk = try await database.readMore(from: cursor, fields: nil)
            indices += paramCounts(in: chunk.records)
        }

        #expect(chunk.cursor == nil)
        #expect(indices == [0, 1, 2, 3, 4])
    }

    private func makeDatabase() throws -> HTTPDatabase {
        let url = try #require(serverURL)
        return HTTPDatabase(url: url, apiKey: ProcessInfo.processInfo.environment["SCOUT_SERVER_API_KEY"])
    }

    private func makeQuery(marker: String) -> CKQuery {
        let query = CKQuery(recordType: "Event", predicate: NSPredicate(format: "name == %@", marker))
        query.sortDescriptors = [NSSortDescriptor(key: "param_count", ascending: true)]
        return query
    }

    private func makeEvent(name: String, index: Int) -> CKRecord {
        let record = CKRecord(recordType: "Event", recordID: CKRecord.ID(recordName: "contract-\(UUID().uuidString)"))
        record["name"] = name
        record["param_count"] = Int64(index)
        record["date"] = eventDate
        record["params"] = eventParams
        return record
    }

    private func paramCounts(in records: [CKRecord]) -> [Int64] {
        records.compactMap { $0["param_count"] as? Int64 }
    }
}
