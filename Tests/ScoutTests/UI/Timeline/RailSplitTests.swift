//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct RailSplitTests {
    private let baseDate = Date(timeIntervalSince1970: 1_700_000_000)
    private func at(_ offset: TimeInterval) -> Date { baseDate.addingTimeInterval(offset) }

    private let deviceID = UUID()
    private let installIDs = [UUID(), UUID(), UUID()]

    /// A rail with three installs sorted oldest → newest.
    private var rail: Rail {
        Rail(
            device: .stub(deviceID: deviceID),
            installs: installIDs.enumerated().map { index, id in
                .stub(installID: id, deviceID: deviceID, date: at(TimeInterval(index * 100)))
            },
            launches: []
        )
    }

    @Test("No anchor event returns nil")
    func testNoAnchor() {
        #expect(rail.split(at: nil) == nil)
    }

    @Test("Anchor without an install id returns nil")
    func testNoInstallID() {
        let anchor = Event.stub(name: "a", installID: nil)
        #expect(rail.split(at: anchor) == nil)
    }

    @Test("Anchor whose install is not in the rail returns nil")
    func testMissingInstall() {
        let anchor = Event.stub(name: "a", installID: UUID())
        #expect(rail.split(at: anchor) == nil)
    }

    @Test("Dated anchor shares its install between both lanes")
    func testDatedAnchor() {
        let anchor = Event.stub(name: "a", installID: installIDs[1], date: at(150))
        let split = rail.split(at: anchor)

        #expect(split?.older == [installIDs[1], installIDs[0]])
        #expect(split?.newer == [installIDs[1], installIDs[2]])
    }

    @Test("Undated anchor keeps its whole install in the older lane")
    func testUndatedAnchor() {
        let anchor = Event.stub(name: "a", installID: installIDs[1], date: nil)
        let split = rail.split(at: anchor)

        #expect(split?.older == [installIDs[1], installIDs[0]])
        #expect(split?.newer == [installIDs[2]])
    }

    @Test("Anchor in the newest install leaves only it in the newer lane")
    func testNewestAnchor() {
        let anchor = Event.stub(name: "a", installID: installIDs[2], date: at(250))
        let split = rail.split(at: anchor)

        #expect(split?.older == [installIDs[2], installIDs[1], installIDs[0]])
        #expect(split?.newer == [installIDs[2]])
    }

    @Test("Anchor in the oldest install leaves only it in the older lane")
    func testOldestAnchor() {
        let anchor = Event.stub(name: "a", installID: installIDs[0], date: at(50))
        let split = rail.split(at: anchor)

        #expect(split?.older == [installIDs[0]])
        #expect(split?.newer == installIDs)
    }
}
