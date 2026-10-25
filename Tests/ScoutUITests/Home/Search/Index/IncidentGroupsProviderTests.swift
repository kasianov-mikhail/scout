//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import Testing

@testable import ScoutUI

@MainActor
struct IncidentGroupsProviderTests {
    private let now = Date()

    @Test("Without an index, groups come from the raw records")
    func rawWithoutIndex() async throws {
        let database = DatabaseStub()
        database.add(makeCrash("c-1", fingerprint: "range", at: -.day), makeCrash("c-2", fingerprint: "range", at: -.hour), makeCrash("c-3", fingerprint: "null", at: -.hour))

        let entries = try await IncidentGroupsProvider<Crash>().fetch(in: database)

        #expect(Set(entries.map(\.id)) == ["null", "range"])
        #expect(entries.allSatisfy { $0.isGroup })
        #expect(database.readCount(of: Crash.recordType) == 1)
    }

    @Test("A fully keyed index names every group without a raw read")
    func indexOnly() async throws {
        let database = DatabaseStub()
        database.add(makeCrash("c-1", fingerprint: "range", at: -.hour))
        database.add(index: IncidentIndex(tallies: [makeTally("range", count: 7)], unkeyed: nil), for: Crash.recordType)

        let entries = try await IncidentGroupsProvider<Crash>().fetch(in: database)

        #expect(entries.map(\.id) == ["range"])
        #expect(entries.map(\.name) == ["NSRangeException"])
        #expect(database.readCount(of: Crash.recordType) == 0)
    }

    @Test("Records written before the key are read raw up to the last unkeyed hour")
    func unkeyedFallback() async throws {
        let database = DatabaseStub()
        let unkeyed = now.addingTimeInterval(-30 * .day)..<now.addingTimeInterval(-20 * .day)
        database.add(
            makeCrash("old-shared", fingerprint: "range", at: -25 * .day),
            makeCrash("old-only", fingerprint: "legacy", at: -22 * .day),
            makeCrash("new", fingerprint: "late", at: -.hour)
        )
        database.add(
            index: IncidentIndex(tallies: [makeTally("range", count: 3, firstHour: now.addingTimeInterval(-.day))], unkeyed: unkeyed),
            for: Crash.recordType
        )

        let entries = try await IncidentGroupsProvider<Crash>().fetch(in: database)

        #expect(Set(entries.map(\.id)) == ["range", "legacy"])

        guard case .tally(let shared)? = entries.first(where: { $0.id == "range" }) else {
            Issue.record("The shared fingerprint should stay a tally")
            return
        }
        #expect(shared.count == 4)
        #expect(shared.firstHour < now.addingTimeInterval(-24 * .day))
        #expect(entries.first { $0.id == "legacy" }?.isGroup == true)
        #expect(database.readCount(of: Crash.recordType) == 1)
    }

    @Test("Keyed records before the end of the unkeyed window are counted once, by the raw read")
    func keyedInsideUnkeyedWindow() async throws {
        let database = DatabaseStub()
        let unkeyed = now.addingTimeInterval(-30 * .day)..<now.addingTimeInterval(-20 * .day)
        database.add(
            makeCrash("keyed-before", fingerprint: "range", at: -40 * .day),
            makeCrash("keyed-inside", fingerprint: "range", at: -25 * .day),
            makeCrash("legacy-inside", fingerprint: "range", at: -22 * .day),
            makeCrash("keyed-after", fingerprint: "range", at: -.day)
        )
        database.add(
            index: IncidentIndex(tallies: [makeTally("range", count: 1, firstHour: now.addingTimeInterval(-.day))], unkeyed: unkeyed),
            for: Crash.recordType
        )

        let entries = try await IncidentGroupsProvider<Crash>().fetch(in: database)

        guard case .tally(let tally)? = entries.first, entries.count == 1 else {
            Issue.record("The fingerprint should merge into one tally")
            return
        }
        #expect(tally.count == 4)
        #expect(tally.firstHour < now.addingTimeInterval(-39 * .day))
        #expect(database.readCount(of: Crash.recordType) == 1)
    }

    private func makeCrash(_ id: String, fingerprint: String, at offset: TimeInterval) -> Record {
        var record = Record(recordType: Crash.recordType, recordID: id)
        record["name"] = fingerprint == "range" ? "NSRangeException" : "crash-\(fingerprint)"
        record["fingerprint"] = fingerprint
        record["date"] = now.addingTimeInterval(offset)
        return record
    }

    private func makeTally(_ fingerprint: String, count: Int, firstHour: Date? = nil) -> IncidentTally {
        IncidentTally(fingerprint: fingerprint, name: "NSRangeException", count: count, firstHour: firstHour ?? now)
    }
}

extension IncidentSearchEntry {
    fileprivate var isGroup: Bool {
        if case .group = self {
            return true
        }
        return false
    }
}
