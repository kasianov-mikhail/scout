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

@Suite("Native incident tallies")
struct NativeIncidentTalliesTests {
    let database = NativeDatabase.inMemory()
    let range = TestDate.reference..<TestDate.reference.addingTimeInterval(2 * .day)

    @Test("Counts each fingerprint and keeps the hour of its first occurrence")
    func tallies() async throws {
        try await database.write(record: makeCrash(id: "c-1", fingerprint: "A", at: 10 * .hour + 20 * .minute))
        try await database.write(record: makeCrash(id: "c-2", fingerprint: "A", at: 30 * .hour))
        try await database.write(record: makeCrash(id: "c-3", fingerprint: "B", at: 12 * .hour))

        let tallies = try await database.incidentTallies(recordType: CrashEntry.recordType, in: range)

        #expect(
            tallies.sorted { $0.fingerprint < $1.fingerprint } == [
                IncidentTally(fingerprint: "A", count: 2, firstHour: TestDate.reference.addingTimeInterval(10 * .hour)),
                IncidentTally(fingerprint: "B", count: 1, firstHour: TestDate.reference.addingTimeInterval(12 * .hour)),
            ]
        )
    }

    @Test("A record without a fingerprint has no tally")
    func missingFingerprint() async throws {
        try await database.write(record: makeCrash(id: "c-1", fingerprint: nil, at: 10 * .hour))

        let tallies = try await database.incidentTallies(recordType: CrashEntry.recordType, in: range)

        #expect(tallies == [])
    }

    @Test("Hangs are tallied apart from crashes")
    func hangs() async throws {
        try await database.write(record: makeCrash(id: "c-1", fingerprint: "A", at: 10 * .hour))
        var hang = Record(recordType: HangEntry.recordType, recordID: "h-1")
        hang["name"] = "Main Thread Blocked"
        hang["fingerprint"] = "H"
        hang["date"] = TestDate.reference.addingTimeInterval(11 * .hour)
        try await database.write(record: hang)

        let tallies = try await database.incidentTallies(recordType: HangEntry.recordType, in: range)

        #expect(tallies.map(\.fingerprint) == ["H"])
    }

    private func makeCrash(id: String, fingerprint: String?, at offset: TimeInterval) -> Record {
        var record = Record(recordType: CrashEntry.recordType, recordID: id)
        record["name"] = "NSRangeException"
        record["fingerprint"] = fingerprint
        record["date"] = TestDate.reference.addingTimeInterval(offset)
        record["app_version"] = "1.2.0"
        return record
    }
}
