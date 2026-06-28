//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct CrashGroupTests {
    @MainActor
    @Test("Provider exposes grouped crashes")
    func providerExposesGroupedCrashes() async throws {
        let database = DatabaseStub()
        database.add(
            makeRecord(name: "NSRangeException", fingerprint: "range", date: Date().addingTimeInterval(-20)),
            makeRecord(name: "NSRangeException", fingerprint: "range", date: Date().addingTimeInterval(-10)),
            makeRecord(name: "Fatal error", fingerprint: "fatal", date: Date().addingTimeInterval(-5))
        )

        let provider = CrashProvider()
        await provider.fetch(in: database)

        let groups = try #require(provider.groups)
        #expect(groups.map(\.fingerprint) == ["fatal", "range"])
        #expect(groups.first(where: { $0.fingerprint == "range" })?.count == 2)
        #expect(database.readCount(of: Crash.recordType) == 1)
    }

    @Test("Groups crashes by fingerprint")
    func groupsCrashesByFingerprint() {
        let sessionID = UUID()
        let crashes = [
            Crash.sample(name: "NSRangeException", fingerprint: "range", date: Date(timeIntervalSince1970: 10), sessionID: sessionID),
            Crash.sample(name: "NSRangeException", fingerprint: "range", date: Date(timeIntervalSince1970: 20), sessionID: sessionID),
            Crash.sample(name: "Fatal error", fingerprint: "fatal", date: Date(timeIntervalSince1970: 30), sessionID: UUID()),
        ]

        let groups = CrashGroup.groups(from: crashes)

        #expect(groups.count == 2)
        #expect(groups.first?.fingerprint == "fatal")
        #expect(groups.first(where: { $0.fingerprint == "range" })?.count == 2)
        #expect(groups.first(where: { $0.fingerprint == "range" })?.affectedSessions == 1)
    }

    @Test("Sorts occurrences in each group by recency")
    func sortsOccurrencesByRecency() throws {
        let older = Crash.sample(name: "NSRangeException", fingerprint: "range", date: Date(timeIntervalSince1970: 10))
        let newer = Crash.sample(name: "NSRangeException", fingerprint: "range", date: Date(timeIntervalSince1970: 20))

        let group = try #require(CrashGroup.groups(from: [older, newer]).first)

        #expect(group.crashes.map(\.id) == [newer.id, older.id])
        #expect(group.firstDate == older.date)
        #expect(group.lastDate == newer.date)
    }

    private func makeRecord(name: String, fingerprint: String, date: Date) -> Record {
        var record = Record(recordType: Crash.recordType, recordID: UUID().uuidString)
        record["name"] = name
        record["fingerprint"] = fingerprint
        record["date"] = date
        record["uuid"] = record.recordID
        return record
    }
}
