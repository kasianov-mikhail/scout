//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import HostedConnector
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
            guard let cursor = chunk.cursor else {
                break
            }
            chunk = try await cursor.next(nil)
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

        // The server forward-marks the device as active that day across all
        // three windows; shared data may push the counts higher.
        #expect(point.dau >= 1)
        #expect(point.wau >= 1)
        #expect(point.mau >= 1)
    }

    @Test("A written Visit marker round-trips")
    func visitRoundTrip() async throws {
        let database = try makeDatabase()
        var record = Record(recordType: "Visit", recordID: "contract-\(UUID().uuidString)")
        record["device_id"] = UUID().uuidString
        record["date"] = eventDate

        try await database.write(record: record)
        let restored = try await database.lookup(recordName: record.recordID, fields: nil)

        #expect(restored.recordType == "Visit")
        #expect(restored["date"] == eventDate)
    }

    @Test("The retention table counts a written Install and its return visit")
    func retentionCohort() async throws {
        let database = try makeDatabase()
        let install = UUID().uuidString
        let installDay = eventDate.startOfDay

        try await database.write(records: [
            makeInstall(installID: install, date: installDay),
            makeSession(installID: install, startDate: installDay.addingTimeInterval(3600)),
        ])

        let week = installDay.startOfWeek
        let cohorts = try await database.retention(in: week..<week.addingDay(14))
        let cohort = try #require(cohorts.first { $0.id == week })

        // Our install anchors the cohort and is active on D0; shared data may
        // add more installs to the same week, so assert a lower bound.
        #expect(cohort.size >= 1)
        let d0 = try #require(cohort.retention.first ?? nil)
        #expect(d0 > 0)
    }

    @Test("The retention table splits a cohort by OS version")
    func retentionSegments() async throws {
        let database = try makeDatabase()
        let install = UUID().uuidString
        let installDay = eventDate.startOfDay
        // A unique OS name isolates this segment from any shared server data.
        let system = "contract-\(UUID().uuidString)"

        var session = makeSession(installID: install, startDate: installDay.addingTimeInterval(3600))
        session["os_version"] = "\(system).2"
        var crash = makeCrash(appVersion: "1.0")
        crash["install_id"] = install

        try await database.write(records: [
            makeInstall(installID: install, date: installDay),
            session,
            crash,
        ])

        let week = installDay.startOfWeek
        let cohorts = try await database.retention(in: week..<week.addingDay(14))
        let cohort = try #require(cohorts.first { $0.id == week })
        let segment = try #require(cohort.segments.first { $0.name == system })

        #expect(segment.size == 1)
        #expect(segment.retention.first == 1)
        #expect(segment.crashes == 1)
        #expect(segment.hangs == 0)
    }

    @Test("Sessions aggregate into a per-version series")
    func versionedSessionSeries() async throws {
        let database = try makeDatabase()
        // A unique version isolates this series from any shared server data.
        let version = "contract-\(UUID().uuidString)"

        var first = makeSession(installID: UUID().uuidString, startDate: eventDate)
        first["app_version"] = version
        var second = makeSession(installID: UUID().uuidString, startDate: eventDate)
        second["app_version"] = version
        try await database.write(records: [first, second])

        let series = try await database.lifecycleSeries(
            matching: LifecycleSeriesQuery(
                name: SessionEntry.recordType,
                byVersion: true,
                range: eventDate.startOfDay..<eventDate.startOfDay.addingDay()
            )
        )
        let sessions = try #require(series.first { $0.version == version })

        #expect(sessions.name == "Session")
        #expect(sessions.points.map(\.value).reduce(0, +) == 2)
    }

    @Test("An event source reaches a custom event named like the Session counter")
    func eventSourceUnshadowsSession() async throws {
        let database = try makeDatabase()
        let hour = Date(timeIntervalSince1970: Double(Int.random(in: 400_000...450_000)) * 3600)
        let events = EventSeriesQuery(name: "Session", bucket: .hour, range: hour..<hour.addingTimeInterval(3600))
        let sessions = LifecycleSeriesQuery(name: SessionEntry.recordType, bucket: .hour, range: events.range)

        func total(_ series: [MetricSeries]) -> Double {
            series.flatMap(\.points).map(\.value).reduce(0, +)
        }

        let eventsBefore = try await total(database.eventSeries(matching: events))
        let sessionsBefore = try await total(database.lifecycleSeries(matching: sessions))

        var event = makeEvent(name: "Session", index: 0)
        event["date"] = hour
        let session = makeSession(installID: UUID().uuidString, startDate: hour)
        try await database.write(records: [event, session])

        let eventsAfter = try await total(database.eventSeries(matching: events))
        let sessionsAfter = try await total(database.lifecycleSeries(matching: sessions))

        #expect(eventsAfter - eventsBefore == 1)
        #expect(sessionsAfter - sessionsBefore == 1)
    }

    @Test("First crashes per install aggregate under the VersionCrash series")
    func versionCrashSeries() async throws {
        let database = try makeDatabase()
        // A unique version isolates this series from any shared server data.
        let version = "contract-\(UUID().uuidString)"
        let install = UUID().uuidString

        var first = makeCrash(appVersion: version)
        first["install_id"] = install
        var second = makeCrash(appVersion: version)
        second["install_id"] = install
        try await database.write(records: [first, second])

        let series = try await database.lifecycleSeries(
            matching: LifecycleSeriesQuery(
                name: MarkerEntry.crashName,
                byVersion: true,
                range: eventDate.startOfDay..<eventDate.startOfDay.addingDay()
            )
        )
        let crashes = try #require(series.first { $0.version == version })

        #expect(crashes.points.map(\.value).reduce(0, +) == 1)
    }

    @Test("Crash threads survive the round trip")
    func crashThreads() async throws {
        let database = try makeDatabase()
        let threads = try JSONEncoder().encode([CrashThread(crashed: true, frames: ["0 MyApp + 4096"])])
        var record = makeCrash(appVersion: "contract-\(UUID().uuidString)")
        record["threads"] = threads

        try await database.write(records: [record])
        let restored = try await database.lookup(recordName: record.recordID, fields: ["threads"])

        #expect(restored["threads"] == threads)
    }

    @Test("Resource exceptions count per kind and version")
    func resourceSeries() async throws {
        let database = try makeDatabase()
        let version = "contract-\(UUID().uuidString)"

        try await database.write(records: [
            makeResourceException(kind: "cpu", appVersion: version),
            makeResourceException(kind: "cpu", appVersion: version),
            makeResourceException(kind: "disk_write", appVersion: version),
        ])

        let series = try await database.lifecycleSeries(
            matching: LifecycleSeriesQuery(
                name: ResourceEntry.recordType,
                byVersion: true,
                range: eventDate.startOfDay..<eventDate.startOfDay.addingDay()
            )
        )
        let resources = series.filter { $0.version == version }

        #expect(resources.map(\.category) == ["cpu", "disk_write"])
        #expect(resources.map { $0.points.map(\.value).reduce(0, +) } == [2, 1])
    }

    @Test("Screen views count per screen and version")
    func screenSeries() async throws {
        let database = try makeDatabase()
        let version = "contract-\(UUID().uuidString)"

        try await database.write(records: [
            makeScreen(name: "Feed", appVersion: version),
            makeScreen(name: "Feed", appVersion: version),
            makeScreen(name: "Profile", appVersion: version),
        ])

        let series = try await database.lifecycleSeries(
            matching: LifecycleSeriesQuery(
                name: ScreenEntry.recordType,
                byVersion: true,
                range: eventDate.startOfDay..<eventDate.startOfDay.addingDay()
            )
        )
        let screens = series.filter { $0.version == version }

        #expect(screens.map(\.category) == ["Feed", "Profile"])
        #expect(screens.map { $0.points.map(\.value).reduce(0, +) } == [2, 1])
    }

    @Test("A screen keeps its end date and previous screen")
    func screenRoundTrip() async throws {
        let database = try makeDatabase()
        var record = makeScreen(name: "Feed", appVersion: "contract")
        record["previous"] = "Home"
        record["end_date"] = eventDate.addingTimeInterval(30)

        try await database.write(record: record)
        let restored = try await database.lookup(recordName: record.recordID, fields: nil)

        #expect(restored.recordType == "Screen")
        #expect(restored["category"] == "Feed")
        #expect(restored["previous"] == "Home")
        #expect(restored["date"] == eventDate)
        #expect(restored["end_date"] == eventDate.addingTimeInterval(30))
    }

    @Test("Conditions count per kind and version")
    func conditionSeries() async throws {
        let database = try makeDatabase()
        let version = "contract-\(UUID().uuidString)"

        try await database.write(records: [
            makeCondition(kind: "memory_warning", appVersion: version),
            makeCondition(kind: "memory_warning", appVersion: version),
            makeCondition(kind: "thermal_serious", appVersion: version),
        ])

        let series = try await database.lifecycleSeries(
            matching: LifecycleSeriesQuery(
                name: ConditionEntry.recordType,
                byVersion: true,
                range: eventDate.startOfDay..<eventDate.startOfDay.addingDay()
            )
        )
        let conditions = series.filter { $0.version == version }

        #expect(conditions.map(\.category) == ["memory_warning", "thermal_serious"])
        #expect(conditions.map { $0.points.map(\.value).reduce(0, +) } == [2, 1])
    }

    @Test("A condition keeps its kind and value")
    func conditionRoundTrip() async throws {
        let database = try makeDatabase()
        let record = makeCondition(kind: "memory_critical", appVersion: "contract")

        try await database.write(record: record)
        let restored = try await database.lookup(recordName: record.recordID, fields: nil)

        #expect(restored.recordType == "Condition")
        #expect(restored["category"] == "memory_critical")
        #expect(restored["value"] == 52_428_800.0)
        #expect(restored["date"] == eventDate)
    }

    @Test("Exit counts sum per reason and version")
    func exitSeries() async throws {
        let database = try makeDatabase()
        let version = "contract-\(UUID().uuidString)"

        try await database.write(records: [
            makeExit(reason: "watchdog", count: 2, appVersion: version),
            makeExit(reason: "watchdog", count: 3, appVersion: version),
            makeExit(reason: "normal", count: 40, appVersion: version),
        ])

        let series = try await database.lifecycleSeries(
            matching: LifecycleSeriesQuery(
                name: ExitReason.metricName,
                byVersion: true,
                range: eventDate.startOfDay..<eventDate.startOfDay.addingDay()
            )
        )
        let exits = series.filter { $0.version == version }

        #expect(exits.map(\.category) == ["normal", "watchdog"])
        #expect(exits.map { $0.points.map(\.value).reduce(0, +) } == [40, 5])
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
        let crashes = try await database.read(matching: query, fields: Crash.desiredKeys).records.map(Crash.init)

        #expect(crashes.count == 2)
        #expect(crashes.allSatisfy { $0.name == "SIGSEGV" })
    }

    @Test("A crash keeps its source and window start")
    func crashSourceRoundTrip() async throws {
        let database = try makeDatabase()
        var record = makeCrash(appVersion: "contract")
        record["source"] = "metrickit"
        record["date_start"] = eventDate.addingTimeInterval(-600)

        try await database.write(record: record)
        let crash = try Crash(record: try await database.lookup(recordName: record.recordID, fields: Crash.desiredKeys))

        #expect(crash.source == .metricKit(windowStart: eventDate.addingTimeInterval(-600)))
        #expect(crash.date == eventDate)
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
        let hangs = try await database.read(matching: query, fields: Hang.desiredKeys).records.map(Hang.init)

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
            matching: MetricSeriesQuery(
                category: category,
                values: .int,
                bucket: .hour,
                range: eventDate.startOfDay..<eventDate.startOfDay.addingDay()
            )
        )
        let bucketSeries = try #require(series.first { $0.name == marker })

        #expect(bucketSeries.category == category)
        #expect(bucketSeries.points.map(\.value).reduce(0, +) == 2)
    }

    @Test("A metric series round-trips a name carrying reserved query characters")
    func specialCharacterNameSeries() async throws {
        let database = try makeDatabase()
        // Reserved delimiters (& = + ? /) and spaces must survive percent
        // encoding on the way to the server, or the name filter silently
        // mismatches and the series comes back empty.
        let marker = "Save & Exit / C++ ?=\(UUID().uuidString)"
        let category = LatencyBuckets.category(for: 0.1)

        try await database.write(records: [
            makeMetric(name: marker, category: category),
            makeMetric(name: marker, category: category),
        ])

        let series = try await database.metricSeries(
            matching: MetricSeriesQuery(
                name: marker,
                category: category,
                values: .int,
                range: eventDate.startOfDay..<eventDate.startOfDay.addingDay()
            )
        )
        let matched = try #require(series.first { $0.name == marker })

        #expect(matched.category == category)
        #expect(matched.points.map(\.value).reduce(0, +) == 2)
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
        record["device_id"] = UUID().uuidString
        record["start_date"] = startDate
        return record
    }

    private func makeInstall(installID: String, date: Date) -> Record {
        var record = Record(recordType: "Install", recordID: installID)
        record["install_id"] = installID
        record["date"] = date
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

    private func makeExit(reason: String, count: Int, appVersion: String) -> Record {
        var record = Record(recordType: "DailyMetric", recordID: "contract-\(UUID().uuidString)")
        record["name"] = "exit"
        record["category"] = reason
        record["value"] = count
        record["app_version"] = appVersion
        record["date"] = eventDate
        return record
    }

    private func makeResourceException(kind: String, appVersion: String) -> Record {
        var record = Record(recordType: "ResourceException", recordID: "contract-\(UUID().uuidString)")
        record["name"] = "CPU Exception"
        record["category"] = kind
        record["value"] = 92.5
        record["app_version"] = appVersion
        record["date"] = eventDate
        return record
    }

    private func makeScreen(name: String, appVersion: String) -> Record {
        var record = Record(recordType: "Screen", recordID: "contract-\(UUID().uuidString)")
        record["category"] = name
        record["app_version"] = appVersion
        record["session_id"] = UUID().uuidString
        record["date"] = eventDate
        return record
    }

    private func makeCondition(kind: String, appVersion: String) -> Record {
        var record = Record(recordType: "Condition", recordID: "contract-\(UUID().uuidString)")
        record["category"] = kind
        record["value"] = 52_428_800.0
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
