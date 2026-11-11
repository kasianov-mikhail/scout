//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout
@testable import ScoutUI

@MainActor
@Suite("Incident tiles provider")
struct IncidentTilesProviderTests {
    @Test("The list falls back to the loaded page when the index is missing")
    func missingIndex() async throws {
        let database = DatabaseStub()
        database.add(Crash.stub(name: "NSRangeException", date: Date()).record)

        let provider = IncidentTilesProvider<Crash>()
        await provider.fetchAgain(in: database)

        let result = try #require(provider.result)
        let tiles = try result.get()

        #expect(tiles.map(\.name) == ["NSRangeException"])
        #expect(tiles.map(\.count) == [1])
        #expect(database.readCount(of: Crash.recordType) == 1)
    }

    @Test("Switching to a narrower range drops the records of the wider one")
    func narrowerRange() async throws {
        let database = DatabaseStub()
        let now = Date()
        database.add(Crash.stub(name: "Old", date: now.addingTimeInterval(-90 * 86_400)).record)
        database.add(Crash.stub(name: "Recent", date: now).record)

        let provider = IncidentTilesProvider<Crash>(range: .year)
        await provider.fetchAgain(in: database)

        provider.range = .week
        await provider.fetchAgain(in: database)

        let result = try #require(provider.result)
        let tiles = try result.get()

        #expect(tiles.map(\.name) == ["Recent"])
        #expect(tiles.map(\.count) == [1])
    }

    @Test("Unkeyed incidents are read raw and counted")
    func unkeyedRecords() async throws {
        let database = DatabaseStub()
        let now = Date()
        let keyed = Crash.stub(name: "Keyed", fingerprint: "A", date: now)
        let unkeyed = Crash.stub(name: "Unkeyed", fingerprint: "B", date: now.addingTimeInterval(-2 * 3600))
        database.add(keyed.record, unkeyed.record)
        database.add(
            index: IncidentIndex(
                tallies: [IncidentTally(fingerprint: "A", name: "Keyed", count: 1, firstHour: now.startOfHour)],
                unkeyed: now.addingTimeInterval(-3 * 3600)..<now.addingTimeInterval(-3600)
            ),
            for: Crash.recordType
        )

        let provider = IncidentTilesProvider<Crash>()
        await provider.fetchAgain(in: database)

        let result = try #require(provider.result)
        let tiles = try result.get()

        #expect(tiles.map(\.name) == ["Keyed", "Unkeyed"])
        #expect(tiles.map(\.count) == [1, 1])
        #expect(database.readCount(of: Crash.recordType) == 2)
    }
}
