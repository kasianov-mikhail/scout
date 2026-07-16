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
        #expect(
            checkout.points.map(\.date) == [TestDate.reference.addingTimeInterval(10 * .hour).millisecondsSince1970])
    }

    @Test("Session records round-trip their captured environment")
    func sessionEnvironmentRoundTrip() async throws {
        var record = makeSessionRecord(id: "s-1", device: "a", day: 0)
        record["build_number"] = "412"
        record["os_version"] = "iOS 17.4"
        record["locale"] = "en_US"
        record["channel"] = "TestFlight"
        try await database.write(record: record)

        let query = RecordQuery(recordType: Session.self)
        let chunk = try await database.read(
            matching: query, fields: ["build_number", "os_version", "locale", "channel"])
        let read = try #require(chunk.records.first)

        #expect(read["build_number"] == "412")
        #expect(read["os_version"] == "iOS 17.4")
        #expect(read["locale"] == "en_US")
        #expect(read["channel"] == "TestFlight")
    }

    @Test("Device records round-trip the hardware model")
    func deviceModelRoundTrip() async throws {
        try await database.write(record: makeDeviceRecord(id: "d-1", model: "iPhone16,1"))

        let query = RecordQuery(recordType: Device.self)
        let chunk = try await database.read(matching: query, fields: ["device_id", "model"])
        let record = try #require(chunk.records.first)

        #expect(record["device_id"] == "d-1")
        #expect(record["model"] == "iPhone16,1")
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

    @Test("Activity merges visit markers with sessions without double counting")
    func activityFromMarkers() async throws {
        try await database.write(record: makeVisitRecord(device: "a", day: 0))
        try await database.write(record: makeVisitRecord(device: "b", day: 0))
        try await database.write(record: makeSessionRecord(id: "s-1", device: "a", day: 0))
        try await database.write(record: makeVisitRecord(device: "a", day: 1))

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

@Suite("Schema bootstrap healing")
struct SchemaBootstrapTests {
    // Simulates the schema an older app published: Device@1 without `model`.
    private func publishStaleDeviceSchema(to cloud: ScoutDBTesting.InMemoryDatabase) async throws {
        let current = try #require(EntityCatalog.definition(for: DeviceEntry.recordType))
        let stale = EntityDefinition(
            entity: current.entity,
            version: current.version,
            fields: current.fields.filter { $0.name != "model" },
            envelopeDate: current.envelopeDate,
            unique: current.unique,
            views: current.views
        )
        try await SchemaRegistry(database: cloud).publish(stale)
    }

    @Test("A stale published Device schema without model blocks reads until the local schema is registered")
    func staleSchemaHealing() async throws {
        let cloud = ScoutDBTesting.InMemoryDatabase()
        try await publishStaleDeviceSchema(to: cloud)

        // A fresh launch: a new registry over the same CloudKit, before bootstrap.
        let registry = SchemaRegistry(database: cloud)
        let database = NativeDatabase(store: EntityStore(database: cloud, registry: registry))

        let query = RecordQuery(recordType: Device.self)

        await #expect(throws: SchemaError.self) {
            _ = try await database.read(matching: query, fields: ["device_id", "model"])
        }

        await EntityCatalog.register(into: registry)

        try await database.write(record: makeDeviceRecord(id: "d-1", model: "iPhone16,1"))
        let chunk = try await database.read(matching: query, fields: ["device_id", "model"])
        #expect(chunk.records.first?["model"] == "iPhone16,1")

        // Reconcile republishes the local schema so later launches preload it clean.
        await EntityCatalog.reconcile(registry: SchemaRegistry(database: cloud), database: cloud)
        let republished = try await SchemaRegistry(database: cloud).definition(for: DeviceEntry.recordType)
        #expect(republished.fields.contains { $0.name == "model" })
    }

    @Test("A backend self-registers its schema, so reads work without setup()")
    func selfRegistration() async throws {
        let cloud = ScoutDBTesting.InMemoryDatabase()
        try await publishStaleDeviceSchema(to: cloud)

        // Build the backend the way Backend.cloudKit does — with a registration task —
        // but never call setup(). The read must still resolve `model`.
        let registry = SchemaRegistry(database: cloud)
        let database = NativeDatabase(
            store: EntityStore(database: cloud, registry: registry),
            registration: Task { await EntityCatalog.register(into: registry) }
        )

        try await database.write(record: makeDeviceRecord(id: "d-1", model: "iPhone16,1"))
        let chunk = try await database.read(
            matching: RecordQuery(recordType: Device.self), fields: ["device_id", "model"])
        #expect(chunk.records.first?["model"] == "iPhone16,1")
    }
}

func makeDeviceRecord(id: String, model: String) -> Record {
    var record = Record(recordType: DeviceEntry.recordType, recordID: id)
    record["date"] = TestDate.reference
    record["device_id"] = id
    record["model"] = model
    return record
}

func makeVisitRecord(device: String, day: Int) -> Record {
    var record = Record(recordType: VisitEntry.recordType, recordID: "\(device)-\(day)")
    record["date"] = TestDate.reference.addingTimeInterval(TimeInterval(day) * .day + .hour)
    record["device_id"] = device
    record["install_id"] = "install-\(device)"
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
