//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import ScoutDB
import ScoutDBTesting
import Testing

@testable import Scout

@Suite("MatrixSeries")
struct MatrixSeriesTests {
    let database: NativeDatabase
    let range = TestDate.reference..<TestDate.reference.addingTimeInterval(2 * .day)

    init() async throws {
        let cloud = ScoutDBTesting.InMemoryDatabase()
        let registry = SchemaRegistry(database: cloud)
        for definition in EntityCatalog.definitions {
            try await registry.register(definition)
        }
        database = NativeDatabase(store: EntityStore(database: cloud, registry: registry))
    }

    @Test("Event counts come back as week matrices")
    func eventMatrices() async throws {
        try await database.write(record: makeEventRecord(id: "e-1", name: "purchase"))
        try await database.write(record: makeEventRecord(id: "e-2", name: "purchase"))
        try await database.write(record: makeEventRecord(id: "e-3", name: "tap"))

        let query = RecordQuery(recordType: GridMatrix<Int>.self, filters: range.dateFilters)
        let matrices: [GridMatrix<Int>] = try await database.readAll(matching: query)

        let purchase = try #require(matrices.first { $0.name == "purchase" })
        #expect(purchase.date == TestDate.reference.startOfWeek)
        #expect(purchase.cells.map(\.value).reduce(0, +) == 2)

        let eventDate = TestDate.reference.addingTimeInterval(10 * .hour)
        let cell = try #require(purchase.cells.first)
        #expect(purchase.date.addingTimeInterval(TimeInterval(cell.secondsSinceBase)) == eventDate)
    }

    @Test("A name filter narrows event matrices")
    func namedEventMatrices() async throws {
        try await database.write(record: makeEventRecord(id: "e-1", name: "purchase"))
        try await database.write(record: makeEventRecord(id: "e-2", name: "tap"))

        let query = RecordQuery(
            recordType: GridMatrix<Int>.self,
            filters: range.dateFilters + [RecordQuery.Filter(field: "name", op: .equals, value: .string("tap"))]
        )
        let matrices: [GridMatrix<Int>] = try await database.readAll(matching: query)

        #expect(matrices.map(\.name) == ["tap"])
    }

    @Test("Session matrices carry the app version")
    func sessionMatrices() async throws {
        try await database.write(record: makeSessionRecord(id: "s-1", device: "a", day: 0))
        try await database.write(record: makeSessionRecord(id: "s-2", device: "b", day: 0))

        let query = RecordQuery(
            recordType: GridMatrix<Int>.self,
            filters: range.dateFilters + [
                RecordQuery.Filter(field: "name", op: .equals, value: .string(SessionEntry.recordType))
            ]
        )
        let matrices: [GridMatrix<Int>] = try await database.readAll(matching: query)
        let matrix = try #require(matrices.first)

        #expect(matrix.name == SessionEntry.recordType)
        #expect(matrix.version == "1.2.0")
        #expect(matrix.cells.map(\.value).reduce(0, +) == 2)
    }

    @Test("Hangs aggregate into a per-version matrix")
    func hangMatrices() async throws {
        var hang = Record(recordType: HangEntry.recordType, recordID: "h-1")
        hang["name"] = "Main Thread Blocked"
        hang["date"] = TestDate.reference.addingTimeInterval(2 * .hour)
        hang["app_version"] = "1.2.0"
        hang["session_id"] = "session-1"
        try await database.write(record: hang)

        let query = RecordQuery(
            recordType: GridMatrix<Int>.self,
            filters: range.dateFilters + [
                RecordQuery.Filter(field: "name", op: .equals, value: .string(HangEntry.recordType))
            ]
        )
        let matrices: [GridMatrix<Int>] = try await database.readAll(matching: query)
        let matrix = try #require(matrices.first)

        #expect(matrix.name == HangEntry.recordType)
        #expect(matrix.version == "1.2.0")
        #expect(matrix.cells.map(\.value).reduce(0, +) == 1)
    }

    @Test("Version installs and crashed installs synthesize from raw records")
    func versionMarkers() async throws {
        var version = Record(recordType: VersionEntry.recordType, recordID: "v-1")
        version["date"] = TestDate.reference.addingTimeInterval(.hour)
        version["app_version"] = "1.2.0"
        version["build_number"] = "42"
        version["install_id"] = "install-a"
        try await database.write(record: version)

        for (id, install) in [("c-1", "install-a"), ("c-2", "install-a"), ("c-3", "install-b")] {
            var crash = Record(recordType: CrashEntry.recordType, recordID: id)
            crash["name"] = "SIGSEGV"
            crash["date"] = TestDate.reference.addingTimeInterval(2 * .hour)
            crash["app_version"] = "1.2.0"
            crash["install_id"] = install
            crash["session_id"] = "session-1"
            try await database.write(record: crash)
        }

        let installs: [GridMatrix<Int>] = try await database.readAll(
            matching: RecordQuery(
                recordType: GridMatrix<Int>.self,
                filters: range.dateFilters + [
                    RecordQuery.Filter(field: "name", op: .equals, value: .string(MarkerEntry.installName))
                ]
            )
        )
        #expect(installs.first?.cells.map(\.value).reduce(0, +) == 1)
        #expect(installs.first?.version == "1.2.0")

        let crashed: [GridMatrix<Int>] = try await database.readAll(
            matching: RecordQuery(
                recordType: GridMatrix<Int>.self,
                filters: range.dateFilters + [
                    RecordQuery.Filter(field: "name", op: .equals, value: .string(MarkerEntry.crashName))
                ]
            )
        )
        #expect(crashed.first?.cells.map(\.value).reduce(0, +) == 2)
    }

    @Test("Double metric matrices carry name and category")
    func doubleMetricMatrices() async throws {
        var record = Record(recordType: DoubleMetricsEntry.recordType, recordID: "m-1")
        record["name"] = "latency"
        record["category"] = "recorder"
        record["value"] = 1.5
        record["date"] = TestDate.reference.addingTimeInterval(10 * .hour)
        record["session_id"] = "session-1"
        try await database.write(record: record)

        let query = RecordQuery(recordType: GridMatrix<Double>.self, filters: range.dateFilters)
        let matrices: [GridMatrix<Double>] = try await database.readAll(matching: query)
        let matrix = try #require(matrices.first)

        #expect(matrix.name == "latency")
        #expect(matrix.category == "recorder")
        #expect(matrix.cells.map(\.value) == [1.5])
    }
}
