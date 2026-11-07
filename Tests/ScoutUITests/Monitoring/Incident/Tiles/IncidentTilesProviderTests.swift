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
}
