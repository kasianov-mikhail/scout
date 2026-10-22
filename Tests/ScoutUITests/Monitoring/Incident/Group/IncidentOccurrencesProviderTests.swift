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
struct IncidentOccurrencesProviderTests {
    @Test("A tallied group with more occurrences than loaded reads them by fingerprint")
    func readsByFingerprint() async {
        let loaded = Crash.stub(fingerprint: "A")
        let database = DatabaseStub()
        database.add(loaded.record, Crash.stub(fingerprint: "A").record, Crash.stub(fingerprint: "A").record, Crash.stub(fingerprint: "B").record)

        let group = IncidentGroup.groups(
            from: [loaded],
            tallies: ["A": IncidentTally(fingerprint: "A", name: "NSRangeException", count: 3, firstHour: Date().addingTimeInterval(-.day))]
        )[0]
        let provider = IncidentOccurrencesProvider(group: group)
        #expect(provider.records == nil)

        await provider.fetchIfNeeded(in: database)

        #expect(provider.records?.count == 3)
        #expect(provider.records?.allSatisfy { $0.fingerprint == "A" } == true)
        #expect(database.readCount(of: Crash.recordType) == 1)
    }

    @Test("A complete or partial group keeps its loaded records without a read")
    func keepsLoadedRecords() async {
        let crashes = [Crash.stub(fingerprint: "A"), Crash.stub(fingerprint: "A")]
        let database = DatabaseStub()

        for group in [IncidentGroup.groups(from: crashes)[0], IncidentGroup.groups(from: crashes, hasMore: true)[0]] {
            let provider = IncidentOccurrencesProvider(group: group)
            await provider.fetchIfNeeded(in: database)

            #expect(provider.records?.map(\.id) == group.records.map(\.id))
        }
        #expect(database.readCount(of: Crash.recordType) == 0)
    }

    @Test("A search tally loads its group by fingerprint and keeps the tallied count")
    func loadsTally() async {
        let database = DatabaseStub()
        database.add(Crash.stub(name: "NSRangeException", fingerprint: "A").record, Crash.stub(name: "NSRangeException", fingerprint: "A").record, Crash.stub(fingerprint: "B").record)
        let firstHour = Date().addingTimeInterval(-30 * .day)

        let provider = IncidentOccurrencesProvider<Crash>(tally: IncidentTally(fingerprint: "A", name: "NSRangeException", count: 9, firstHour: firstHour))
        #expect(provider.records == nil)

        await provider.fetchIfNeeded(in: database)

        #expect(provider.records?.count == 2)
        #expect(provider.group.id == "A")
        #expect(provider.group.name == "NSRangeException")
        #expect(provider.group.count == 9)
        #expect(provider.group.firstDate == firstHour)
        #expect(provider.group.hasAllRecords == false)
        #expect(database.readCount(of: Crash.recordType) == 1)
    }

    @Test("A tally whose records are gone loads an empty feed instead of failing")
    func emptyTally() async {
        let provider = IncidentOccurrencesProvider<Crash>(tally: IncidentTally(fingerprint: "A", name: "NSRangeException", count: 1, firstHour: Date()))

        await provider.fetchIfNeeded(in: DatabaseStub())

        #expect(provider.records?.isEmpty == true)
        #expect(provider.error == nil)
    }
}
