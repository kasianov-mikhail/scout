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
@testable import ScoutNative
@testable import ScoutTestSupport

@Suite("NativeSeries")
struct NativeSeriesTests {
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

    @Test("Event counts come back as hour-bucket series")
    func eventSeries() async throws {
        try await database.write(record: makeEventRecord(id: "e-1", name: "purchase"))
        try await database.write(record: makeEventRecord(id: "e-2", name: "purchase"))
        try await database.write(record: makeEventRecord(id: "e-3", name: "tap"))

        let series = try await database.series(matching: SeriesQuery(bucket: .hour, range: range))

        let purchase = try #require(series.first { $0.name == "purchase" })
        #expect(purchase.points.map(\.value) == [.int(2)])
        #expect(purchase.points.first?.date == TestDate.reference.addingTimeInterval(10 * .hour).millisecondsSince1970)
    }

    @Test("A name filter narrows the series")
    func namedEventSeries() async throws {
        try await database.write(record: makeEventRecord(id: "e-1", name: "purchase"))
        try await database.write(record: makeEventRecord(id: "e-2", name: "tap"))

        let series = try await database.series(
            matching: SeriesQuery(name: "tap", bucket: .hour, range: range)
        )

        #expect(series.map(\.name) == ["tap"])
    }

    @Test("Day buckets fold hourly sums")
    func dayBuckets() async throws {
        var early = makeMetricRecord(id: "m-1", name: "latency", value: 3)
        early["date"] = TestDate.reference.addingTimeInterval(9 * .hour)
        try await database.write(record: early)
        try await database.write(record: makeMetricRecord(id: "m-2", name: "latency", value: 4))

        let series = try await database.series(
            matching: SeriesQuery(name: "latency", bucket: .day, range: range)
        )

        let latency = try #require(series.first)
        #expect(latency.category == "timer")
        #expect(latency.points.map(\.value) == [.int(7)])
        #expect(latency.points.first?.date == TestDate.reference.millisecondsSince1970)
    }

    @Test("Session series carry the app version")
    func sessionSeries() async throws {
        try await database.write(record: makeSessionRecord(id: "s-1", device: "a", day: 0))
        try await database.write(record: makeSessionRecord(id: "s-2", device: "b", day: 0))

        let series = try await database.series(
            matching: SeriesQuery(name: SessionEntry.recordType, bucket: .day, byVersion: true, range: range)
        )

        let sessions = try #require(series.first)
        #expect(sessions.name == SessionEntry.recordType)
        #expect(sessions.version == "1.2.0")
        #expect(sessions.points.map(\.value) == [.int(2)])
    }

    @Test("Hangs aggregate into a per-version series")
    func hangSeries() async throws {
        var hang = Record(recordType: HangEntry.recordType, recordID: "h-1")
        hang["name"] = "Main Thread Blocked"
        hang["date"] = TestDate.reference.addingTimeInterval(2 * .hour)
        hang["app_version"] = "1.2.0"
        hang["session_id"] = "session-1"
        try await database.write(record: hang)

        let series = try await database.series(
            matching: SeriesQuery(name: HangEntry.recordType, bucket: .day, byVersion: true, range: range)
        )

        let hangs = try #require(series.first)
        #expect(hangs.name == HangEntry.recordType)
        #expect(hangs.version == "1.2.0")
        #expect(hangs.points.map(\.value) == [.int(1)])
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

        let installs = try await database.series(
            matching: SeriesQuery(name: VersionEntry.recordType, bucket: .day, byVersion: true, range: range)
        )
        #expect(installs.first?.points.map(\.value) == [.int(1)])
        #expect(installs.first?.version == "1.2.0")

        let crashed = try await database.series(
            matching: SeriesQuery(name: MarkerEntry.crashName, bucket: .day, byVersion: true, range: range)
        )
        #expect(crashed.first?.points.map(\.value) == [.int(2)])
        #expect(crashed.first?.version == "1.2.0")
    }

    @Test("Double metric series carry name and category")
    func doubleMetricSeries() async throws {
        var record = Record(recordType: DoubleMetricsEntry.recordType, recordID: "m-1")
        record["name"] = "latency"
        record["category"] = "recorder"
        record["value"] = 1.5
        record["date"] = TestDate.reference.addingTimeInterval(10 * .hour)
        record["session_id"] = "session-1"
        try await database.write(record: record)

        let series = try await database.series(matching: SeriesQuery(bucket: .hour, range: range))
        let latency = try #require(series.first { $0.name == "latency" })

        #expect(latency.category == "recorder")
        #expect(latency.points.map(\.value) == [.double(1.5)])
    }
}
