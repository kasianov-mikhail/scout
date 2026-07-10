//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

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
        let restored = try await database.lookup(recordName: record.recordID, fields: nil)

        #expect(restored.recordType == "Event")
        #expect(restored.recordID == record.recordID)
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
        let restored = try await database.lookup(recordName: record.recordID, fields: ["name"])

        #expect(restored["name"] == "login")
        #expect(restored.fields["param_count"] == nil)
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

    @Test("The active-user series counts a written Session")
    func activitySeries() async throws {
        let database = try makeDatabase()
        let install = UUID().uuidString
        let day = eventDate.startOfDay

        try await database.write(record: makeSession(installID: install, startDate: day.addingTimeInterval(3600)))

        let series = try await database.activity(in: day..<day.addingDay())
        let point = try #require(series.first { $0.date == Int64((day.timeIntervalSince1970 * 1000).rounded()) })

        // The server forward-marks the install as active that day across all
        // three windows; shared data may push the counts higher.
        #expect(point.dau >= 1)
        #expect(point.wau >= 1)
        #expect(point.mau >= 1)
    }

    @Test("Sessions aggregate into a per-version matrix")
    func versionedSessionMatrix() async throws {
        let database = try makeDatabase()
        // A unique version isolates this matrix from any shared server data.
        let version = "contract-\(UUID().uuidString)"

        var first = makeSession(installID: UUID().uuidString, startDate: eventDate)
        first["app_version"] = version
        var second = makeSession(installID: UUID().uuidString, startDate: eventDate)
        second["app_version"] = version
        try await database.write(records: [first, second])

        let query = RecordQuery(
            recordType: GridMatrix<Int>.self,
            filters: [
                RecordQuery.Filter(field: "name", op: .equals, value: .string("Session")),
                RecordQuery.Filter(field: "app_version", op: .equals, value: .string(version)),
            ]
        )
        let matrices: [GridMatrix<Int>] = try await database.readAll(matching: query)

        #expect(matrices.count == 1)
        let matrix = try #require(matrices.first)
        #expect(matrix.version == version)
        #expect(matrix.cells.map(\.value).reduce(0, +) == 2)
    }

    @Test("Crashes filter by app version on the server")
    func crashesByVersion() async throws {
        let database = try makeDatabase()
        // A unique version isolates these crashes from any shared server data.
        let version = "contract-\(UUID().uuidString)"

        try await database.write(records: [
            makeCrash(appVersion: version),
            makeCrash(appVersion: version),
            makeCrash(appVersion: "other-\(UUID().uuidString)"),
        ])

        let query = RecordQuery(
            recordType: Crash.self,
            filters: [RecordQuery.Filter(field: "app_version", op: .equals, value: .string(version))]
        )
        let crashes: [Crash] = try await database.readAll(matching: query, fields: Crash.desiredKeys)

        #expect(crashes.count == 2)
        #expect(crashes.allSatisfy { $0.name == "SIGSEGV" })
    }

    @Test("Hangs filter by app version on the server")
    func hangsByVersion() async throws {
        let database = try makeDatabase()
        // A unique version isolates these hangs from any shared server data.
        let version = "contract-\(UUID().uuidString)"

        try await database.write(records: [
            makeHang(appVersion: version),
            makeHang(appVersion: version),
            makeHang(appVersion: "other-\(UUID().uuidString)"),
        ])

        let query = RecordQuery(
            recordType: Hang.self,
            filters: [RecordQuery.Filter(field: "app_version", op: .equals, value: .string(version))]
        )
        let hangs: [Hang] = try await database.readAll(matching: query, fields: Hang.desiredKeys)

        #expect(hangs.count == 2)
        #expect(hangs.allSatisfy { $0.name == "Main Thread Blocked" })
    }

    @Test("Timer bucket increments surface in the metric series by bucket category")
    func timerBucketSeries() async throws {
        let database = try makeDatabase()
        // A unique name isolates this series from any shared server data.
        let marker = "contract-\(UUID().uuidString)"
        let category = LatencyBuckets.category(for: 0.1)

        try await database.write(records: [
            makeMetric(name: marker, category: category),
            makeMetric(name: marker, category: category),
        ])

        let series = try await database.metricSeries(
            Int.self,
            category: category,
            in: eventDate.startOfDay..<eventDate.startOfDay.addingDay()
        )
        let bucketSeries = try #require(series.first { $0.name == marker })

        #expect(bucketSeries.category == category)
        #expect(bucketSeries.points.map(\.value.doubleValue).reduce(0, +) == 2)
    }

    @Test("A reachability ping succeeds against a live server")
    func reachabilityPing() async throws {
        let database = try makeDatabase()
        try await database.ping()
    }

    private func makeDatabase() throws -> HTTPDatabase {
        let url = try #require(serverURL)
        return HTTPDatabase(url: url, apiKey: ProcessInfo.processInfo.environment["SCOUT_SERVER_API_KEY"])
    }

    private func makeQuery(marker: String) -> RecordQuery {
        RecordQuery(
            recordType: Event.self,
            filters: [RecordQuery.Filter(field: "name", op: .equals, value: .string(marker))],
            sort: [RecordQuery.Sort(field: "param_count", ascending: true)]
        )
    }

    private func makeEvent(name: String, index: Int) -> Record {
        var record = Record(recordType: "Event", recordID: "contract-\(UUID().uuidString)")
        record["name"] = name
        record["param_count"] = Int64(index)
        record["date"] = eventDate
        record["params"] = eventParams
        return record
    }

    private func makeSession(installID: String, startDate: Date) -> Record {
        var record = Record(recordType: "Session", recordID: "contract-\(UUID().uuidString)")
        record["session_id"] = UUID().uuidString
        record["install_id"] = installID
        record["start_date"] = startDate
        return record
    }

    private func makeMetric(name: String, category: String) -> Record {
        var record = Record(recordType: "IntMetric", recordID: "contract-\(UUID().uuidString)")
        record["name"] = name
        record["category"] = category
        record["value"] = 1
        record["date"] = eventDate
        record["session_id"] = UUID().uuidString
        return record
    }

    private func makeCrash(appVersion: String) -> Record {
        var record = Record(recordType: "Crash", recordID: "contract-\(UUID().uuidString)")
        record["name"] = "SIGSEGV"
        record["app_version"] = appVersion
        record["session_id"] = UUID().uuidString
        record["date"] = eventDate
        return record
    }

    private func makeHang(appVersion: String) -> Record {
        var record = Record(recordType: "Hang", recordID: "contract-\(UUID().uuidString)")
        record["name"] = "Main Thread Blocked"
        record["duration"] = 4.2
        record["app_version"] = appVersion
        record["session_id"] = UUID().uuidString
        record["date"] = eventDate
        return record
    }

    private func paramCounts(in records: [Record]) -> [Int64] {
        records.compactMap { $0["param_count"] }
    }
}
