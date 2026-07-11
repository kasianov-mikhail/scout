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

@Suite("NativeDatabase")
struct NativeDatabaseTests {
    let database: NativeDatabase

    init() async throws {
        let cloud = ScoutDBTesting.InMemoryDatabase()
        let registry = SchemaRegistry(database: cloud)
        for definition in EntityCatalog.definitions {
            try await registry.register(definition)
        }
        database = NativeDatabase(store: EntityStore(database: cloud, registry: registry))
    }

    @Test("Event records round-trip through the store")
    func eventRoundTrip() async throws {
        try await database.write(record: makeEventRecord(id: "e-1", name: "purchase"))

        let query = RecordQuery(
            recordType: Event.self,
            filters: [RecordQuery.Filter(field: "name", op: .equals, value: .string("purchase"))]
        )
        let chunk = try await database.read(matching: query, fields: Event.desiredKeys)
        let record = try #require(chunk.records.first)

        #expect(chunk.records.count == 1)
        #expect(record.recordID == "e-1")
        #expect(record["uuid"] == "e-1")
        #expect(record["name"] == "purchase")
        #expect(record["level"] == "info")
        #expect(record["param_count"] == Int64(2))
    }

    @Test("Reads honor sort and paginate through a cursor")
    func pagination() async throws {
        for (index, hour) in [12, 10, 14].enumerated() {
            var record = makeEventRecord(id: "e-\(index)", name: "tap")
            record["date"] = TestDate.reference.addingTimeInterval(TimeInterval(hour) * .hour)
            try await database.write(record: record)
        }

        let query = RecordQuery(
            recordType: Event.self,
            sort: [RecordQuery.Sort(field: "date", ascending: false)]
        )
        let first = try await database.read(matching: query, fields: nil, limit: 2)
        #expect(first.records.map(\.recordID) == ["e-2", "e-0"])

        let cursor = try #require(first.cursor)
        let rest = try await database.readMore(from: cursor, fields: nil)
        #expect(rest.records.map(\.recordID) == ["e-1"])
        #expect(rest.cursor == nil)
    }

    @Test("Lookup restores a record by its identifier")
    func lookup() async throws {
        try await database.write(record: makeEventRecord(id: "e-9", name: "open"))

        let record = try await database.lookup(recordName: "e-9", fields: ["params"])
        let params: Data? = record["params"]

        #expect(record.recordType == EventEntry.recordType)
        #expect(params == Data("{}".utf8))

        await #expect(throws: RecordNotFoundError.self) {
            _ = try await database.lookup(recordName: "ghost", fields: nil)
        }
    }

    @Test("Metric series come back per name within a category")
    func metricSeries() async throws {
        try await database.write(record: makeMetricRecord(id: "m-1", name: "checkout", value: 3))
        try await database.write(record: makeMetricRecord(id: "m-2", name: "checkout", value: 4))
        try await database.write(record: makeMetricRecord(id: "m-3", name: "signup", value: 9))
        var foreign = makeMetricRecord(id: "m-4", name: "checkout", value: 100)
        foreign["category"] = "counter"
        try await database.write(record: foreign)

        let range = TestDate.reference..<TestDate.reference.addingTimeInterval(.day)
        let series = try await database.metricSeries(Int.self, category: "timer", in: range)

        #expect(Set(series.map(\.name)) == ["checkout", "signup"])
        let checkout = try #require(series.first { $0.name == "checkout" })
        #expect(checkout.points.map(\.value) == [.int(7)])
        #expect(checkout.points.map(\.date) == [TestDate.reference.addingTimeInterval(10 * .hour).millisecondsSince1970])
    }

    @Test("Activity derives DAU, WAU, and MAU from sessions")
    func activity() async throws {
        try await database.write(record: makeSessionRecord(id: "s-1", device: "a", day: 0))
        try await database.write(record: makeSessionRecord(id: "s-2", device: "b", day: 0))
        try await database.write(record: makeSessionRecord(id: "s-3", device: "a", day: 1))

        let range = TestDate.reference..<TestDate.reference.addingTimeInterval(2 * .day)
        let points = try await database.activity(in: range)

        #expect(points.count == 2)
        #expect(points.first?.dau == 2)
        #expect(points.last?.dau == 1)
        #expect(points.last?.wau == 2)
        #expect(points.last?.mau == 2)
    }
}

func makeEventRecord(id: String, name: String) -> Record {
    var record = Record(recordType: EventEntry.recordType, recordID: id)
    record["name"] = name
    record["level"] = "info"
    record["params"] = Data("{}".utf8)
    record["param_count"] = Int64(2)
    record["date"] = TestDate.reference.addingTimeInterval(10 * .hour)
    record["uuid"] = id
    record["session_id"] = "session-1"
    record["device_id"] = "device-1"
    record["install_id"] = "install-1"
    record["launch_id"] = "launch-1"
    return record
}

func makeMetricRecord(id: String, name: String, value: Int64) -> Record {
    var record = Record(recordType: IntMetricsEntry.recordType, recordID: id)
    record["name"] = name
    record["category"] = "timer"
    record["value"] = value
    record["date"] = TestDate.reference.addingTimeInterval(10 * .hour)
    record["session_id"] = "session-1"
    return record
}

func makeSessionRecord(id: String, device: String, day: Int) -> Record {
    var record = Record(recordType: SessionEntry.recordType, recordID: id)
    record["start_date"] = TestDate.reference.addingTimeInterval(TimeInterval(day) * .day + .hour)
    record["end_date"] = TestDate.reference.addingTimeInterval(TimeInterval(day) * .day + 2 * .hour)
    record["session_id"] = id
    record["app_version"] = "1.2.0"
    record["device_id"] = device
    record["install_id"] = "install-\(device)"
    return record
}
