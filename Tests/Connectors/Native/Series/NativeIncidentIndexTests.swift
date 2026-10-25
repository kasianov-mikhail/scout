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

@Suite("Native incident index")
struct NativeIncidentIndexTests {
    let database = NativeDatabase.inMemory()
    let range = TestDate.reference..<TestDate.reference.addingTimeInterval(2 * .day)

    @Test("Counts each fingerprint and keeps the hour of its first occurrence")
    func tallies() async throws {
        try await database.write(record: makeCrash(id: "c-1", fingerprint: "A", at: 10 * .hour + 20 * .minute))
        try await database.write(record: makeCrash(id: "c-2", fingerprint: "A", at: 30 * .hour))
        try await database.write(record: makeCrash(id: "c-3", fingerprint: "B", at: 12 * .hour))

        let tallies = try #require(try await database.incidentIndex(recordType: CrashEntry.recordType, in: range)).tallies

        #expect(
            tallies.sorted { $0.fingerprint < $1.fingerprint } == [
                IncidentTally(fingerprint: "A", name: "NSRangeException", count: 2, firstHour: TestDate.reference.addingTimeInterval(10 * .hour)),
                IncidentTally(fingerprint: "B", name: "NSRangeException", count: 1, firstHour: TestDate.reference.addingTimeInterval(12 * .hour)),
            ]
        )
    }

    @Test("A crash without a stored fingerprint is tallied under the one it decodes to")
    func missingFingerprint() async throws {
        let record = makeCrash(id: "c-1", fingerprint: nil, at: 10 * .hour)
        try await database.write(record: record)

        let tallies = try #require(try await database.incidentIndex(recordType: CrashEntry.recordType, in: range)).tallies

        let crash = try Crash(record: record)
        #expect(tallies.map(\.fingerprint) == [crash.fingerprint])
    }

    @Test("The index names each fingerprint and keys a name that holds a bar")
    func names() async throws {
        var record = makeCrash(id: "c-1", fingerprint: "A", at: 10 * .hour)
        record["name"] = "Fatal error | index out of range"
        try await database.write(record: record)

        let index = try await database.incidentIndex(recordType: CrashEntry.recordType, in: range)

        #expect(index?.tallies.map(\.name) == ["Fatal error | index out of range"])
        #expect(index?.tallies.map(\.fingerprint) == ["A"])
        #expect(index?.unkeyed == nil)
    }

    @Test("Records written without the key mark the hours a raw read must cover")
    func unkeyedHours() async throws {
        try await database.write(record: makeCrash(id: "c-1", fingerprint: "A", at: 30 * .hour))
        try await writeLegacyCrashes(at: [10 * .hour + 5 * .minute, 20 * .hour])

        let index = try await database.incidentIndex(recordType: CrashEntry.recordType, in: range)

        #expect(index?.tallies.map(\.fingerprint) == ["A"])
        #expect(index?.unkeyed == TestDate.reference.addingTimeInterval(10 * .hour)..<TestDate.reference.addingTimeInterval(21 * .hour))
    }

    @Test("Keyed hours before the end of the unkeyed window are left to the raw read")
    func keyedBeforeUnkeyedEnd() async throws {
        try await database.write(record: makeCrash(id: "c-1", fingerprint: "A", at: 5 * .hour))
        try await database.write(record: makeCrash(id: "c-2", fingerprint: "A", at: 15 * .hour))
        try await database.write(record: makeCrash(id: "c-3", fingerprint: "A", at: 30 * .hour))
        try await writeLegacyCrashes(at: [10 * .hour + 5 * .minute, 20 * .hour])

        let index = try await database.incidentIndex(recordType: CrashEntry.recordType, in: range)

        #expect(index?.unkeyed == TestDate.reference.addingTimeInterval(10 * .hour)..<TestDate.reference.addingTimeInterval(21 * .hour))
        #expect(index?.tallies == [IncidentTally(fingerprint: "A", name: "NSRangeException", count: 1, firstHour: TestDate.reference.addingTimeInterval(30 * .hour))])
    }

    @Test("Hangs are tallied apart from crashes under the fingerprint the feed groups by")
    func hangs() async throws {
        try await database.write(record: makeCrash(id: "c-1", fingerprint: "A", at: 10 * .hour))
        var hang = Record(recordType: HangEntry.recordType, recordID: "h-1")
        hang["name"] = "Main Thread Blocked"
        hang["fingerprint"] = "H"
        hang["date"] = TestDate.reference.addingTimeInterval(11 * .hour)
        try await database.write(record: hang)

        let tallies = try #require(try await database.incidentIndex(recordType: HangEntry.recordType, in: range)).tallies

        let decoded = try Hang(record: hang)
        #expect(tallies.map(\.fingerprint) == [decoded.fingerprint])
        #expect(tallies.map(\.name) == ["Main Thread Blocked"])
    }

    private func writeLegacyCrashes(at offsets: [TimeInterval]) async throws {
        let store = try await database.resolve()
        let legacy = offsets.enumerated().map { offset, time in
            EntityWrite(values: ["date": .date(TestDate.reference.addingTimeInterval(time))], uuid: "legacy-\(offset)")
        }
        try await store.write(legacy, entity: CrashEntry.recordType)
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
