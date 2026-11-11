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

@Suite("Incident tiles")
struct IncidentTileTests {
    private let now = Date(timeIntervalSince1970: 1_700_000_000)
    private let range = IncidentRange.week

    @Test("A tally keeps its count when the loaded page is smaller")
    func indexCountWins() {
        let tiles = tileList(
            records: [.stub(name: "NSRangeException", fingerprint: "A", date: now)],
            current: [tally("A", name: "NSRangeException", count: 12)],
            previous: []
        )

        #expect(tiles.map(\.count) == [12])
    }

    @Test("Loaded records fill a count the index does not have")
    func rawCountFillsGap() {
        let tiles = tileList(
            records: [
                .stub(name: "NSRangeException", fingerprint: "A", date: now),
                .stub(name: "NSRangeException", fingerprint: "A", date: now.addingTimeInterval(-3600)),
            ],
            current: [],
            previous: []
        )

        #expect(tiles.map(\.count) == [2])
    }

    @Test("A group that only appears in the previous range stays in the list")
    func previousOnly() {
        let tiles = tileList(
            records: [],
            current: [],
            previous: [tally("B", name: "SIGABRT", count: 2)]
        )

        #expect(tiles.map(\.count) == [0])
        #expect(tiles.map(\.previous) == [2])
        #expect(tiles.map(\.changeLabel) == ["−2"])
        #expect(tiles.map(\.subtitle) == [""])
    }

    @Test("A group without previous occurrences reads as new")
    func newGroup() {
        let tiles = tileList(
            records: [.stub(name: "NSRangeException", fingerprint: "A", date: now)],
            current: [tally("A", name: "NSRangeException", count: 1)],
            previous: []
        )

        #expect(tiles.map(\.changeLabel) == ["new"])
        #expect(tiles.map(\.isAccented) == [true])
    }

    @Test("A falling count is not accented")
    func fallingCount() {
        let tiles = tileList(
            records: [],
            current: [tally("A", name: "NSRangeException", count: 3)],
            previous: [tally("A", name: "NSRangeException", count: 5)]
        )

        #expect(tiles.map(\.changeLabel) == ["−2"])
        #expect(tiles.map(\.isAccented) == [false])
    }

    @Test("A tile always draws seven bars")
    func bars() {
        let tiles = tileList(
            records: [.stub(name: "NSRangeException", fingerprint: "A", date: now)],
            current: [tally("A", name: "NSRangeException", count: 1)],
            previous: []
        )

        #expect(tiles.first?.bars.count == MiniChartSeries.sliceCount)
        #expect(tiles.first?.todayCount == 1)
    }

    @Test("Unkeyed records raise the tally and fill the bars")
    func unkeyedRecords() {
        let tiles = tileList(
            records: [],
            legacy: [.stub(name: "NSRangeException", fingerprint: "A", date: now)],
            current: [tally("A", name: "NSRangeException", count: 3)],
            previous: []
        )

        #expect(tiles.map(\.count) == [4])
        #expect(tiles.first?.bars.reduce(0, +) == 1)
        #expect(tiles.first?.todayCount == 1)
    }

    @Test("A group that only appears in the unkeyed records becomes a tile")
    func unkeyedOnlyGroup() {
        let tiles = tileList(
            records: [],
            legacy: [.stub(name: "SIGABRT", fingerprint: "B", date: now)],
            current: [tally("A", name: "NSRangeException", count: 3)],
            previous: []
        )

        #expect(tiles.map(\.name) == ["NSRangeException", "SIGABRT"])
        #expect(tiles.map(\.count) == [3, 1])
    }

    @Test("A record in both the page and the unkeyed read counts once")
    func unkeyedOverlap() {
        let record: Crash = .stub(name: "NSRangeException", fingerprint: "A", date: now)
        let tiles = tileList(
            records: [record],
            legacy: [record],
            current: [],
            previous: []
        )

        #expect(tiles.map(\.count) == [1])
        #expect(tiles.first?.records.count == 1)
        #expect(tiles.first?.todayCount == 1)
    }

    private func tileList(
        records: [Crash],
        legacy: [Crash] = [],
        current: [IncidentTally],
        previous: [IncidentTally]
    ) -> [IncidentTile<Crash>] {
        IncidentTile.tiles(
            records: records,
            legacy: legacy,
            keys: [:],
            current: IncidentIndex(tallies: current, unkeyed: nil),
            previous: IncidentIndex(tallies: previous, unkeyed: nil),
            range: range.range(now: now)
        )
    }

    private func tally(_ fingerprint: String, name: String, count: Int) -> IncidentTally {
        IncidentTally(fingerprint: fingerprint, name: name, count: count, firstHour: now.startOfHour)
    }
}
