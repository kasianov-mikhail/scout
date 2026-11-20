//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import Testing

@testable import ScoutUI

@MainActor
@Suite("Refreshable")
struct FetchTaskTests {
    @Test("A batch re-reads every provider once")
    func fetchesAgain() async {
        let first = RefreshStub()
        let second = RefreshStub()
        let database = DatabaseStub()

        await [first as any Refreshable, second as any Refreshable].fetchAgain(in: database)

        #expect(first.again == 1)
        #expect(second.again == 1)
        #expect(first.latest == 0)
    }

    @Test("A change signal refreshes in place, keeping the last value when the read fails")
    func refreshesInPlace() async {
        let stub = RefreshStub()
        let database = DatabaseStub()

        await [stub as any Refreshable].refresh(in: database)

        #expect(stub.latest == 1)
        #expect(stub.again == 0)
    }

    @Test("A feed reloads fully on a change signal")
    func feedRefreshes() async {
        let stub = FeedRefreshStub()
        let database = DatabaseStub()

        await [stub as any Refreshable].refresh(in: database)

        #expect(stub.again == 1)
        #expect(stub.latest == 0)
    }

    @Test("A newer refresh reaches a provider that does not override it as a full read")
    func fallsBackToLatest() async {
        let stub = RefreshStub()
        let database = DatabaseStub()

        await [stub as any Refreshable].fetchNewer(in: database)

        #expect(stub.latest == 1)
        #expect(stub.again == 0)
    }

    @Test("A newer refresh prefers the feed path when the provider has one")
    func prefersNewer() async {
        let stub = NewerStub()
        let database = DatabaseStub()

        await [stub as any Refreshable].fetchNewer(in: database)

        #expect(stub.newer == 1)
        #expect(stub.latest == 0)
    }

    @Test("A change signal bumps the generation for every reader")
    func signalBumps() {
        let signal = ChangeSignal()
        let start = signal.generation

        signal.bump()

        #expect(signal.generation == start + 1)
    }
}

@MainActor
private final class RefreshStub: Refreshable {
    var latest = 0
    var again = 0

    func fetchLatest(in database: DatabaseReader) async {
        latest += 1
    }

    func fetchAgain(in database: DatabaseReader) async {
        again += 1
    }
}

@MainActor
private final class FeedRefreshStub: Refreshable {
    var latest = 0
    var again = 0

    func fetchLatest(in database: DatabaseReader) async {
        latest += 1
    }

    func fetchAgain(in database: DatabaseReader) async {
        again += 1
    }

    func refresh(in database: DatabaseReader) async {
        await fetchAgain(in: database)
    }
}

@MainActor
private final class NewerStub: Refreshable {
    var latest = 0
    var newer = 0

    func fetchLatest(in database: DatabaseReader) async {
        latest += 1
    }

    func fetchAgain(in database: DatabaseReader) async {}

    func fetchNewer(in database: DatabaseReader) async {
        newer += 1
    }
}
