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
@testable import Support

@Suite("IncidentGroup")
struct IncidentGroupTests {
    @Test("Crashes sharing a fingerprint collapse into one group") func testGroupingByFingerprint() {
        let crashes = [
            Crash.stub(name: "A", fingerprint: "fp1"),
            Crash.stub(name: "A", fingerprint: "fp1"),
            Crash.stub(name: "B", fingerprint: "fp2"),
        ]

        let groups = IncidentGroup.groups(from: crashes)

        #expect(groups.count == 2)
        #expect(groups.map(\.count).sorted() == [1, 2])
    }

    @Test("A symbolicated key merges fingerprints and the rest keep their own")
    func keyedGrouping() {
        let first = Crash.stub(name: "A", fingerprint: "fp1")
        let second = Crash.stub(name: "A", fingerprint: "fp2")
        let third = Crash.stub(name: "B", fingerprint: "fp3")

        let groups = IncidentGroup.groups(
            from: [first, second, third],
            keys: [first.id: "MyApp|Cart.apply()", second.id: "MyApp|Cart.apply()"]
        )

        #expect(Set(groups.map(\.id)) == ["MyApp|Cart.apply()", "fp3"])
        #expect(groups.first { $0.id == "MyApp|Cart.apply()" }?.count == 2)
        #expect(groups.first { $0.id == "MyApp|Cart.apply()" }?.symbol == "Cart.apply()")
        #expect(groups.first { $0.id == "fp3" }?.symbol == nil)
    }

    @Test("The representative is the most recent crash in the group") func testRepresentativeIsLatest() {
        let old = Crash.stub(fingerprint: "fp", date: Date(timeIntervalSince1970: 1000))
        let new = Crash.stub(fingerprint: "fp", date: Date(timeIntervalSince1970: 2000))

        let group = IncidentGroup.groups(from: [old, new])[0]

        #expect(group.representative.id == new.id)
        #expect(group.firstDate == old.date)
        #expect(group.lastDate == new.date)
    }

    @Test("Groups are ordered by most recent occurrence first") func testGroupOrderByRecency() {
        let crashes = [
            Crash.stub(fingerprint: "old", date: Date(timeIntervalSince1970: 1000)),
            Crash.stub(fingerprint: "new", date: Date(timeIntervalSince1970: 2000)),
        ]

        let groups = IncidentGroup.groups(from: crashes)

        #expect(groups.map(\.representative.fingerprint) == ["new", "old"])
    }

    @Test("Ties on recency are broken by occurrence count") func testTieBreakByCount() {
        let date = Date(timeIntervalSince1970: 1000)
        let crashes = [
            Crash.stub(fingerprint: "single", date: date),
            Crash.stub(fingerprint: "double", date: date),
            Crash.stub(fingerprint: "double", date: date),
        ]

        let groups = IncidentGroup.groups(from: crashes)

        #expect(groups.map(\.representative.fingerprint) == ["double", "single"])
    }

    @Test("Affected sessions count distinct sessions") func testAffectedSessions() {
        let session = UUID()
        let crashes = [
            Crash.stub(fingerprint: "fp", sessionID: session),
            Crash.stub(fingerprint: "fp", sessionID: session),
            Crash.stub(fingerprint: "fp", sessionID: UUID()),
            Crash.stub(fingerprint: "fp", sessionID: nil),
        ]

        let group = IncidentGroup.groups(from: crashes)[0]

        #expect(group.affectedSessions == 2)
    }

    @Test("Affected devices count distinct devices") func testAffectedDevices() {
        let device = UUID()
        let crashes = [
            Crash.stub(fingerprint: "fp", deviceID: device),
            Crash.stub(fingerprint: "fp", deviceID: device),
            Crash.stub(fingerprint: "fp", deviceID: UUID()),
            Crash.stub(fingerprint: "fp", deviceID: nil),
        ]

        let group = IncidentGroup.groups(from: crashes)[0]

        #expect(group.affectedDevices == 2)
    }

    @Test("A tally gives the count and the first hour beyond the loaded records")
    func tallyTotals() {
        let now = Date(timeIntervalSince1970: 1_000_000)
        let firstHour = now.addingTimeInterval(-30 * .day)
        let crashes = [
            Crash.stub(fingerprint: "fp", date: now),
            Crash.stub(fingerprint: "fp", date: now.addingTimeInterval(-.hour)),
        ]

        let group = IncidentGroup.groups(
            from: crashes,
            tallies: ["fp": IncidentTally(fingerprint: "fp", count: 10, firstHour: firstHour)],
            hasMore: true
        )[0]

        #expect(group.count == 10)
        #expect(group.firstDate == firstHour)
        #expect(group.lastDate == now)
        #expect(!group.isPartial)
        #expect(group.occurrencesText == "10")
        #expect(group.firstSeenLabel == "First seen")
    }

    @Test("A loaded occurrence from the tally's first hour gives the exact first date")
    func exactFirstDate() {
        let firstHour = Date(timeIntervalSince1970: 3_600_000)
        let crash = Crash.stub(fingerprint: "fp", date: firstHour.addingTimeInterval(10 * .minute))

        let group = IncidentGroup.groups(
            from: [crash],
            tallies: ["fp": IncidentTally(fingerprint: "fp", count: 1, firstHour: firstHour)]
        )[0]

        #expect(group.firstDate == crash.date)
    }

    @Test("A group without a tally is partial while older pages remain")
    func untalliedPartial() {
        let crashes = [Crash.stub(fingerprint: "fp"), Crash.stub(fingerprint: "fp")]

        let partial = IncidentGroup.groups(from: crashes, hasMore: true)[0]
        let complete = IncidentGroup.groups(from: crashes, hasMore: false)[0]

        #expect(partial.isPartial)
        #expect(partial.occurrencesText == "2+")
        #expect(partial.firstSeenLabel == "Earliest loaded")
        #expect(!complete.isPartial)
        #expect(complete.occurrencesText == "2")
    }

    @Test("A symbolicated group adds up the tallies of its fingerprints")
    func symbolicatedTallies() {
        let first = Crash.stub(fingerprint: "fp1", date: Date(timeIntervalSince1970: 2_000_000))
        let second = Crash.stub(fingerprint: "fp2", date: Date(timeIntervalSince1970: 2_000_000))
        let earliest = Date(timeIntervalSince1970: 360_000)

        let group = IncidentGroup.groups(
            from: [first, second],
            keys: [first.id: "MyApp|Cart.apply()", second.id: "MyApp|Cart.apply()"],
            tallies: [
                "fp1": IncidentTally(fingerprint: "fp1", count: 5, firstHour: earliest),
                "fp2": IncidentTally(fingerprint: "fp2", count: 7, firstHour: earliest.addingTimeInterval(.day)),
            ]
        )[0]

        #expect(group.count == 12)
        #expect(group.firstDate == earliest)
    }

    @Test("A fingerprint split over two groups counts its loaded records in each")
    func splitFingerprint() {
        let keyed = Crash.stub(fingerprint: "fp")
        let raw = Crash.stub(fingerprint: "fp")

        let groups = IncidentGroup.groups(
            from: [keyed, raw],
            keys: [keyed.id: "MyApp|Cart.apply()"],
            tallies: ["fp": IncidentTally(fingerprint: "fp", count: 50, firstHour: Date(timeIntervalSince1970: 0))]
        )

        #expect(groups.map(\.count) == [1, 1])
    }

    @Test("Ties on recency are broken by the tallied count")
    func tieBreakByTally() {
        let date = Date(timeIntervalSince1970: 1_000_000)
        let crashes = [
            Crash.stub(fingerprint: "loaded", date: date),
            Crash.stub(fingerprint: "loaded", date: date),
            Crash.stub(fingerprint: "tallied", date: date),
        ]

        let groups = IncidentGroup.groups(
            from: crashes,
            tallies: ["tallied": IncidentTally(fingerprint: "tallied", count: 9, firstHour: Date(timeIntervalSince1970: 0))]
        )

        #expect(groups.map(\.id) == ["tallied", "loaded"])
    }

    @Test("Devices and sessions are lower bounds until every occurrence is loaded")
    func lowerBoundDevices() {
        let crash = Crash.stub(fingerprint: "fp", deviceID: UUID(), sessionID: UUID())

        let group = IncidentGroup.groups(
            from: [crash],
            tallies: ["fp": IncidentTally(fingerprint: "fp", count: 3, firstHour: Date(timeIntervalSince1970: 0))]
        )[0]

        #expect(!group.hasAllRecords)
        #expect(group.devicesText == "1+")
        #expect(group.sessionsText == "1+")
    }
}
