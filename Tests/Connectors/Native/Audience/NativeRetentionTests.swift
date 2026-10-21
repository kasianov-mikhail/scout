//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ConnectorSupport
import Foundation
import ScoutDB
import ScoutDBTesting
import Testing

@testable import NativeConnector
@testable import Scout
@testable import Support

@Suite("Native retention from milestone marks")
struct NativeRetentionTests {
    let database: NativeDatabase
    let range = TestDate.reference.addingDay(-7)..<TestDate.reference.addingDay(40)

    init() {
        database = .inMemory()
    }

    private func writeCohort() async throws {
        let installs = [("a", "iOS 18.0", ["day0", "day7"]), ("b", "iOS 18.1", ["day0", "crash"]), ("c", "iOS 17.5", ["day0", "day7", "hang"])]

        for (install, os, names) in installs {
            for name in ["install"] + names {
                try await database.write(record: makeMark(install: install, name: name, os: os))
            }
        }
    }

    @Test("Segments bucket installs by the major version they installed on")
    func segmentsFollowOSVersion() async throws {
        try await writeCohort()

        let cohort = try #require(try await database.retention(in: range).first)

        #expect(cohort.size == 3)
        #expect(cohort.retention[0] == 1)
        #expect(cohort.segments.map(\.name) == ["iOS 18", "iOS 17"])
        #expect(cohort.segments.map(\.size) == [2, 1])

        let latest = try #require(cohort.segments.first)
        #expect(latest.retention[3] == 0.5)
    }

    @Test("Crashes and hangs land in the segment of the install that saw them")
    func incidentsFollowTheirInstall() async throws {
        try await writeCohort()
        try await database.write(record: makeMark(install: "a", name: "crash", os: "iOS 18.0"))

        let cohort = try #require(try await database.retention(in: range).first)

        let latest = try #require(cohort.segments.first)
        #expect(latest.crashes == 2)
        #expect(latest.hangs == 0)

        let older = try #require(cohort.segments.last)
        #expect(older.crashes == 0)
        #expect(older.hangs == 1)
    }

    @Test("A re-sent mark counts once")
    func resentMark() async throws {
        try await writeCohort()
        try await database.write(record: makeMark(install: "a", name: "day7", os: "iOS 18.0"))

        let cohort = try #require(try await database.retention(in: range).first)

        #expect(cohort.retention[3] == 2.0 / 3.0)
    }

    @Test("An install without an OS version counts in the cohort but in no segment")
    func installWithoutOSVersion() async throws {
        try await database.write(record: makeMark(install: "a", name: "install", os: nil))
        try await database.write(record: makeMark(install: "a", name: "day0", os: nil))

        let cohort = try #require(try await database.retention(in: range).first)

        #expect(cohort.size == 1)
        #expect(cohort.retention[0] == 1)
        #expect(cohort.segments.isEmpty)
    }

    @Test("A week whose install marks have not arrived yet has no cohort")
    func weekWithoutInstalls() async throws {
        try await database.write(record: makeMark(install: "a", name: "day1", os: "iOS 18.0"))

        #expect(try await database.retention(in: range).isEmpty)
    }

    @Test("Marks outside the range leave their cohort out")
    func outsideRange() async throws {
        try await writeCohort()

        let later = TestDate.reference.addingDay(7)..<TestDate.reference.addingDay(40)

        #expect(try await database.retention(in: later).isEmpty)
    }

    @Test("The read costs the same however many installs a week has")
    func boundedRead() async throws {
        let small = try await requests(installs: 5)
        let large = try await requests(installs: 60)

        #expect(small.total == large.total)
        #expect(small.records == large.records)
    }

    @Test("Retention from marks matches the per-install build", arguments: [false, true])
    func parity(segmented: Bool) async throws {
        let scenario = RetentionScenario(segmented: segmented)

        for record in scenario.marks {
            try await database.write(record: record)
        }

        for range in [day(0)..<day(75), day(7)..<day(49)] {
            let expected = scenario.cohorts(in: range)

            #expect(expected.contains { $0.segments.isEmpty != segmented })
            #expect(try await database.retention(in: range) == expected)
        }
    }

    private func requests(installs: Int) async throws -> RequestTally {
        let cloud = ScoutDBTesting.InMemoryDatabase()
        let registry = SchemaRegistry(database: cloud)
        let store = EntityStore(database: cloud, registry: registry)
        try await CatalogEntry.publishAll(into: store, registry: registry)

        let database = NativeDatabase { store }
        for index in 0..<installs {
            for name in ["install", "day0", "day1", "crash"] {
                try await database.write(record: makeMark(install: "\(index)", name: name, os: "iOS 18.\(index % 3)"))
            }
        }

        cloud.resetRequests()
        _ = try await database.retention(in: range)
        return cloud.requests
    }
}

private struct RetentionScenario {
    struct Install {
        let id: String
        let day: Int
        let os: String?
        let activeDays: [Int]
        let crashDays: [Int]
        let hangDays: [Int]
    }

    let installs: [Install]

    init(segmented: Bool) {
        installs = (0..<24).map { index in
            Install(
                id: "install-\(index)",
                day: (index * 5) % 60,
                os: segmented || index.isMultiple(of: 3) ? "iOS \(16 + index % 3).\(index % 2)" : nil,
                activeDays: [0] + (1..<45).filter { ($0 * 7 + index) % 4 == 0 },
                crashDays: index.isMultiple(of: 3) ? [2, 40] : [],
                hangDays: index % 4 == 1 ? [10, 31] : []
            )
        }
    }

    var marks: [Record] {
        installs.flatMap { install in
            let days = install.activeDays.filter(RetentionCohort.dayOffsets.contains).map { "day\($0)" }
            let crashes = install.crashDays.contains { $0 < RetentionCohort.horizon } ? ["crash"] : []
            let hangs = install.hangDays.contains { $0 < RetentionCohort.horizon } ? ["hang"] : []

            return (["install"] + days + crashes + hangs).map { name in
                makeMark(install: install.id, name: name, os: install.os, day: install.day)
            }
        }
    }

    func cohorts(in range: Range<Date>) -> [RetentionCohort] {
        RetentionCohort.cohorts(
            installs: installs.map { DatedID(date: day($0.day, hour: 1), id: $0.id) },
            sessions: installs.flatMap { install in
                install.activeDays.map { InstallSession(install: install.id, date: day(install.day + $0, hour: 9), os: install.os) }
            },
            crashes: installs.flatMap { install in install.crashDays.map { DatedID(date: day(install.day + $0, hour: 12), id: install.id) } },
            hangs: installs.flatMap { install in install.hangDays.map { DatedID(date: day(install.day + $0, hour: 12), id: install.id) } },
            range: range,
            now: Date()
        )
    }
}

private func day(_ index: Int, hour: Int = 0) -> Date {
    TestDate.reference.addingDay(index).addingTimeInterval(TimeInterval(hour) * .hour)
}

private func makeMark(install: String, name: String, os: String?, day installDay: Int = 0) -> Record {
    var record = Record(recordType: RetentionMarkEntry.recordType, recordID: "\(install)-\(name)")
    record["date"] = day(installDay, hour: 2)
    record["name"] = name
    record["install_date"] = day(installDay, hour: 1)
    record["os_version"] = os
    record["install_id"] = install
    return record
}
