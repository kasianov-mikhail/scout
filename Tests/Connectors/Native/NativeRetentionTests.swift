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

@Suite("Native retention segments")
struct NativeRetentionTests {
    let database: NativeDatabase
    let range = TestDate.reference.addingDay(-7)..<TestDate.reference.addingDay(40)

    init() {
        database = .inMemory()
    }

    private func writeCohort() async throws {
        for device in ["a", "b", "c"] {
            try await database.write(record: makeInstallRecord(install: "install-\(device)", day: 0))
        }

        try await database.write(record: makeSessionRecord(id: "a-0", device: "a", day: 0, os: "iOS 18.0"))
        try await database.write(record: makeSessionRecord(id: "a-7", device: "a", day: 7, os: "iOS 18.1"))
        try await database.write(record: makeSessionRecord(id: "b-0", device: "b", day: 0, os: "iOS 18.1"))
        try await database.write(record: makeSessionRecord(id: "c-0", device: "c", day: 0, os: "iOS 17.5"))
        try await database.write(record: makeSessionRecord(id: "c-7", device: "c", day: 7, os: "iOS 17.6"))

        try await database.write(record: makeIncidentRecord(entity: CrashEntry.recordType, install: "install-b", day: 0))
        try await database.write(record: makeIncidentRecord(entity: HangEntry.recordType, install: "install-c", day: 7))
    }

    @Test("Segments bucket installs by the major version of their first session")
    func segmentsFollowOSVersion() async throws {
        try await writeCohort()

        let cohorts = try await database.retention(in: range)
        let cohort = try #require(cohorts.first)

        #expect(cohort.size == 3)
        #expect(cohort.segments.map(\.name) == ["iOS 18", "iOS 17"])
        #expect(cohort.segments.map(\.size) == [2, 1])

        let latest = try #require(cohort.segments.first)
        #expect(RetentionCohort.rate(latest.retention, onDay: 7) == 0.5)
    }

    @Test("Crashes and hangs land in the segment of the install that saw them within 30 days, session or not")
    func incidentsFollowTheirInstall() async throws {
        try await writeCohort()
        try await database.write(record: makeIncidentRecord(entity: CrashEntry.recordType, install: "install-a", day: 20))
        try await database.write(record: makeIncidentRecord(entity: HangEntry.recordType, install: "install-a", day: 35))

        let cohorts = try await database.retention(in: range)
        let cohort = try #require(cohorts.first)

        let latest = try #require(cohort.segments.first)
        #expect(latest.crashes == 2)
        #expect(latest.hangs == 0)

        let older = try #require(cohort.segments.last)
        #expect(older.crashes == 0)
        #expect(older.hangs == 1)
    }

    @Test("A session without an OS version leaves its install unsegmented")
    func sessionWithoutOSVersion() async throws {
        try await database.write(record: makeInstallRecord(install: "install-a", day: 0))
        try await database.write(record: makeSessionRecord(id: "a-0", device: "a", day: 0))

        let cohort = try #require(try await database.retention(in: range).first)

        #expect(cohort.size == 1)
        #expect(cohort.segments.count == 0)
    }
}

private func makeInstallRecord(install: String, day: Int) -> Record {
    var record = Record(recordType: InstallEntry.recordType, recordID: install)
    record["date"] = TestDate.reference.addingTimeInterval(TimeInterval(day) * .day + .hour)
    record["install_id"] = install
    return record
}

private func makeIncidentRecord(entity: String, install: String, day: Int) -> Record {
    var record = Record(recordType: entity, recordID: "\(entity)-\(install)-\(day)")
    record["date"] = TestDate.reference.addingTimeInterval(TimeInterval(day) * .day + 3 * .hour)
    record["name"] = "EXC_BAD_ACCESS"
    record["fingerprint"] = "fingerprint"
    record["install_id"] = install
    return record
}
