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

@testable import NativeConnector
@testable import Scout
@testable import Support

@Suite("NativeSeries")
struct NativeSeriesTests {
    let database: NativeDatabase
    let range = TestDate.reference..<TestDate.reference.addingTimeInterval(2 * .day)

    init() {
        database = .inMemory()
    }

    @Test("Event counts come back as hour-bucket series")
    func eventSeries() async throws {
        try await database.write(record: makeEventRecord(id: "e-1", name: "purchase"))
        try await database.write(record: makeEventRecord(id: "e-2", name: "purchase"))
        try await database.write(record: makeEventRecord(id: "e-3", name: "tap"))

        let series = try await database.eventSeries(matching: EventSeriesQuery(bucket: .hour, range: range))

        let purchase = try #require(series.first { $0.name == "purchase" })
        #expect(purchase.points.map(\.value) == [2])
        #expect(purchase.points.first?.date == TestDate.reference.addingTimeInterval(10 * .hour))
    }

    @Test("A name filter narrows the series")
    func namedEventSeries() async throws {
        try await database.write(record: makeEventRecord(id: "e-1", name: "purchase"))
        try await database.write(record: makeEventRecord(id: "e-2", name: "tap"))

        let series = try await database.eventSeries(
            matching: EventSeriesQuery(name: "tap", bucket: .hour, range: range)
        )

        #expect(series.map(\.name) == ["tap"])
    }

    @Test("Day buckets fold hourly sums")
    func dayBuckets() async throws {
        var early = makeMetricRecord(id: "m-1", name: "latency", value: 3)
        early["date"] = TestDate.reference.addingTimeInterval(9 * .hour)
        try await database.write(record: early)
        try await database.write(record: makeMetricRecord(id: "m-2", name: "latency", value: 4))

        let series = try await database.metricSeries(
            matching: MetricSeriesQuery(name: "latency", bucket: .day, range: range)
        )

        let latency = try #require(series.first)
        #expect(latency.category == "timer")
        #expect(latency.points.map(\.value) == [7])
        #expect(latency.points.first?.date == TestDate.reference)
    }

    @Test("Session series carry the app version")
    func sessionSeries() async throws {
        try await database.write(record: makeSessionRecord(id: "s-1", device: "a", day: 0))
        try await database.write(record: makeSessionRecord(id: "s-2", device: "b", day: 0))

        let series = try await database.lifecycleSeries(
            matching: LifecycleSeriesQuery(name: SessionEntry.recordType, bucket: .day, byVersion: true, range: range)
        )

        let sessions = try #require(series.first)
        #expect(sessions.name == SessionEntry.recordType)
        #expect(sessions.version == "1.2.0")
        #expect(sessions.points.map(\.value) == [2])
    }

    @Test("Hangs aggregate into a per-version series")
    func hangSeries() async throws {
        var hang = Record(recordType: HangEntry.recordType, recordID: "h-1")
        hang["name"] = "Main Thread Blocked"
        hang["date"] = TestDate.reference.addingTimeInterval(2 * .hour)
        hang["app_version"] = "1.2.0"
        hang["session_id"] = "session-1"
        try await database.write(record: hang)

        let series = try await database.lifecycleSeries(
            matching: LifecycleSeriesQuery(name: HangEntry.recordType, bucket: .day, byVersion: true, range: range)
        )

        let hangs = try #require(series.first)
        #expect(hangs.name == HangEntry.recordType)
        #expect(hangs.version == "1.2.0")
        #expect(hangs.points.map(\.value) == [1])
    }

    @Test("Exit counts sum per reason and version apart from other daily metrics")
    func exitSeries() async throws {
        try await database.write(record: makeExitRecord(id: "x-1", reason: "watchdog", count: 2))
        try await database.write(record: makeExitRecord(id: "x-2", reason: "watchdog", count: 3))
        try await database.write(record: makeExitRecord(id: "x-3", reason: "normal", count: 40))

        var launch = makeExitRecord(id: "x-4", reason: "400", count: 7)
        launch["name"] = "launch_time"
        try await database.write(record: launch)

        let series = try await database.lifecycleSeries(
            matching: LifecycleSeriesQuery(name: ExitReason.metricName, bucket: .day, byVersion: true, range: range)
        )

        #expect(series.map(\.name) == [ExitReason.metricName, ExitReason.metricName])
        #expect(series.map(\.category) == ["normal", "watchdog"])
        #expect(series.map(\.version) == ["1.2.0", "1.2.0"])
        #expect(series.map { $0.points.map(\.value) } == [[40], [5]])
    }

    @Test("Resource exceptions count per kind and version, not by their amount")
    func resourceSeries() async throws {
        try await database.write(record: makeResourceRecord(id: "r-1", kind: "cpu"))
        try await database.write(record: makeResourceRecord(id: "r-2", kind: "cpu"))
        try await database.write(record: makeResourceRecord(id: "r-3", kind: "disk_write"))

        let series = try await database.lifecycleSeries(
            matching: LifecycleSeriesQuery(name: ResourceEntry.recordType, bucket: .day, byVersion: true, range: range)
        )

        #expect(series.map(\.category) == ["cpu", "disk_write"])
        #expect(series.map { $0.points.map(\.value) } == [[2], [1]])
    }

    @Test("Screen views count per screen and version")
    func screenSeries() async throws {
        try await database.write(record: makeScreenRecord(id: "s-1", name: "Feed"))
        try await database.write(record: makeScreenRecord(id: "s-2", name: "Feed"))
        try await database.write(record: makeScreenRecord(id: "s-3", name: "Profile"))

        let series = try await database.lifecycleSeries(
            matching: LifecycleSeriesQuery(name: ScreenEntry.recordType, bucket: .day, byVersion: true, range: range)
        )

        #expect(series.map(\.category) == ["Feed", "Profile"])
        #expect(series.map(\.version) == ["1.2.0", "1.2.0"])
        #expect(series.map { $0.points.map(\.value) } == [[2], [1]])
    }

    @Test("Conditions count per kind and version, not by their value")
    func conditionSeries() async throws {
        try await database.write(record: makeConditionRecord(id: "c-1", kind: "memory_warning"))
        try await database.write(record: makeConditionRecord(id: "c-2", kind: "memory_warning"))
        try await database.write(record: makeConditionRecord(id: "c-3", kind: "thermal_serious"))

        let series = try await database.lifecycleSeries(
            matching: LifecycleSeriesQuery(name: ConditionEntry.recordType, bucket: .day, byVersion: true, range: range)
        )

        #expect(series.map(\.category) == ["memory_warning", "thermal_serious"])
        #expect(series.map { $0.points.map(\.value) } == [[2], [1]])
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

        let installs = try await database.lifecycleSeries(
            matching: LifecycleSeriesQuery(name: VersionEntry.recordType, bucket: .day, byVersion: true, range: range)
        )
        #expect(installs.first?.points.map(\.value) == [1])
        #expect(installs.first?.version == "1.2.0")

        let crashed = try await database.lifecycleSeries(
            matching: LifecycleSeriesQuery(name: MarkerEntry.crashName, bucket: .day, byVersion: true, range: range)
        )
        #expect(crashed.first?.points.map(\.value) == [2])
        #expect(crashed.first?.version == "1.2.0")
    }

    @Test("An explicit event source reaches a custom event named like a lifecycle counter")
    func eventSourceUnshadowsLifecycleName() async throws {
        try await database.write(record: makeEventRecord(id: "e-1", name: SessionEntry.recordType))
        try await database.write(record: makeEventRecord(id: "e-2", name: SessionEntry.recordType))
        try await database.write(record: makeSessionRecord(id: "s-1", device: "a", day: 0))

        let series = try await database.eventSeries(
            matching: EventSeriesQuery(name: SessionEntry.recordType, bucket: .hour, range: range)
        )

        let event = try #require(series.first)
        #expect(series.count == 1)
        #expect(event.name == SessionEntry.recordType)
        #expect(event.points.map(\.value) == [2])
    }

    @Test("An explicit lifecycle source ignores a same-named custom event")
    func lifecycleSourceIgnoresEvents() async throws {
        try await database.write(record: makeEventRecord(id: "e-1", name: SessionEntry.recordType))
        try await database.write(record: makeSessionRecord(id: "s-1", device: "a", day: 0))
        try await database.write(record: makeSessionRecord(id: "s-2", device: "b", day: 0))

        let series = try await database.lifecycleSeries(
            matching: LifecycleSeriesQuery(
                name: SessionEntry.recordType,
                bucket: .day,
                byVersion: true,
                range: range
            )
        )

        let sessions = try #require(series.first)
        #expect(series.count == 1)
        #expect(sessions.version == "1.2.0")
        #expect(sessions.points.map(\.value) == [2])
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

        let series = try await database.metricSeries(matching: MetricSeriesQuery(bucket: .hour, range: range))
        let latency = try #require(series.first { $0.name == "latency" })

        #expect(latency.category == "recorder")
        #expect(latency.points.map(\.value) == [1.5])
    }

    @Test("A pipe in the category keeps the metric in its own series")
    func pipeInCategory() async throws {
        var record = Record(recordType: DoubleMetricsEntry.recordType, recordID: "m-1")
        record["name"] = "renew"
        record["category"] = "billing|eu"
        record["value"] = 2.5
        record["date"] = TestDate.reference.addingTimeInterval(10 * .hour)
        record["session_id"] = "session-1"
        try await database.write(record: record)

        let series = try await database.metricSeries(matching: MetricSeriesQuery(bucket: .hour, range: range))
        let renew = try #require(series.first { $0.name == "renew" })

        #expect(renew.category == "billing|eu")
        #expect(renew.points.map(\.value) == [2.5])
    }

    @Test("Concurrent crash and crashed-install series share one scan of the crashes")
    func sharedCrashScan() async throws {
        let cloud = ScoutDBTesting.InMemoryDatabase()
        let database = probedDatabase(cloud: cloud)

        for (id, install) in [("c-1", "install-a"), ("c-2", "install-a"), ("c-3", "install-b")] {
            var crash = Record(recordType: CrashEntry.recordType, recordID: id)
            crash["name"] = "SIGSEGV"
            crash["date"] = TestDate.reference.addingTimeInterval(2 * .hour)
            crash["app_version"] = "1.2.0"
            crash["install_id"] = install
            try await database.write(record: crash)
        }
        _ = try await database.lifecycleSeries(matching: lifecycleQuery(name: CrashEntry.recordType))
        cloud.resetRequests()

        async let crashes = database.lifecycleSeries(matching: lifecycleQuery(name: CrashEntry.recordType))
        async let crashed = database.lifecycleSeries(matching: lifecycleQuery(name: MarkerEntry.crashName))

        #expect(try await crashes.first?.points.map(\.value) == [3])
        #expect(try await crashed.first?.points.map(\.value) == [2])
        #expect(cloud.requests[.query] == 1)
    }

    @Test("A daily metric scan downloads only the records of its own name")
    func dailyMetricByName() async throws {
        let cloud = ScoutDBTesting.InMemoryDatabase()
        let database = probedDatabase(cloud: cloud)

        try await database.write(record: makeExitRecord(id: "x-1", reason: "watchdog", count: 2))
        try await database.write(record: makeExitRecord(id: "x-2", reason: "normal", count: 3))

        var launch = makeExitRecord(id: "x-3", reason: "400", count: 7)
        launch["name"] = "launch_time"
        try await database.write(record: launch)

        _ = try await database.lifecycleSeries(matching: lifecycleQuery(name: ExitReason.metricName))
        cloud.resetRequests()

        let series = try await database.lifecycleSeries(matching: lifecycleQuery(name: ExitReason.metricName))

        #expect(series.map(\.category) == ["normal", "watchdog"])
        #expect(cloud.requests.records == 2)
    }

    private func probedDatabase(cloud: ScoutDBTesting.InMemoryDatabase) -> NativeDatabase {
        let probe = ConcurrencyProbe(cloud)
        let registry = SchemaRegistry(database: probe)
        let store = EntityStore(database: probe, registry: registry)
        let registration = Task { try await CatalogEntry.publishAll(into: store, registry: registry) }

        return NativeDatabase {
            try await registration.value
            return store
        }
    }

    private func lifecycleQuery(name: String) -> LifecycleSeriesQuery {
        LifecycleSeriesQuery(name: name, bucket: .day, byVersion: true, range: range)
    }

    private func makeResourceRecord(id: String, kind: String) -> Record {
        var record = Record(recordType: ResourceEntry.recordType, recordID: id)
        record["name"] = "CPU Exception"
        record["category"] = kind
        record["value"] = 92.5
        record["app_version"] = "1.2.0"
        record["date"] = TestDate.reference.addingTimeInterval(3 * .hour)
        return record
    }

    private func makeScreenRecord(id: String, name: String) -> Record {
        var record = Record(recordType: ScreenEntry.recordType, recordID: id)
        record["category"] = name
        record["app_version"] = "1.2.0"
        record["date"] = TestDate.reference.addingTimeInterval(3 * .hour)
        return record
    }

    private func makeConditionRecord(id: String, kind: String) -> Record {
        var record = Record(recordType: ConditionEntry.recordType, recordID: id)
        record["category"] = kind
        record["value"] = 52_428_800.0
        record["app_version"] = "1.2.0"
        record["date"] = TestDate.reference.addingTimeInterval(3 * .hour)
        return record
    }

    private func makeExitRecord(id: String, reason: String, count: Int) -> Record {
        var record = Record(recordType: DailyMetricEntry.recordType, recordID: id)
        record["name"] = ExitReason.metricName
        record["category"] = reason
        record["value"] = count
        record["app_version"] = "1.2.0"
        record["date"] = TestDate.reference.addingTimeInterval(3 * .hour)
        return record
    }
}
