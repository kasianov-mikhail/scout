//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout
@testable import ScoutTestSupport
@testable import ScoutUI

struct RailInitTests {
    @Test("Device with no children has empty installs")
    func testNoChildren() {
        let rail = Rail(
            device: .stub(deviceID: UUID()),
            installs: [], launches: [], sessions: [], events: [], crashes: []
        )
        #expect(rail.installs.isEmpty)
    }

    @Test("Builds the full tree linking children to their parents")
    func testFullTree() {
        let deviceID = UUID()
        let installID = UUID()
        let launchID = UUID()
        let sessionID = UUID()

        let rail = Rail(
            device: .stub(deviceID: deviceID),
            installs: [.stub(installID: installID, deviceID: deviceID)],
            launches: [.stub(launchID: launchID, installID: installID)],
            sessions: [.stub(sessionID: sessionID, launchID: launchID)],
            events: [.stub(name: "e1", sessionID: sessionID)],
            crashes: [.stub(name: "c1", sessionID: sessionID)]
        )

        let session = rail.installs[0].launches[0].sessions[0]
        #expect(session.events.map(\.name) == ["e1"])
        #expect(session.crashes.map(\.name) == ["c1"])
    }

    @Test("Sorts every level by date ascending")
    func testSortingAtAllLevels() {
        let deviceID = UUID()
        let iID1 = UUID()
        let iID2 = UUID()
        let lID1 = UUID()
        let lID2 = UUID()
        let sID1 = UUID()
        let sID2 = UUID()

        let rail = Rail(
            device: .stub(deviceID: deviceID),
            installs: [
                .stub(installID: iID2, deviceID: deviceID, date: TimelineFixture.at(200)),
                .stub(installID: iID1, deviceID: deviceID, date: TimelineFixture.at(100)),
            ],
            launches: [
                .stub(launchID: lID2, installID: iID1, startDate: TimelineFixture.at(2000)),
                .stub(launchID: lID1, installID: iID1, startDate: TimelineFixture.at(1000)),
            ],
            sessions: [
                .stub(sessionID: sID2, launchID: lID1, startDate: TimelineFixture.at(20_000)),
                .stub(sessionID: sID1, launchID: lID1, startDate: TimelineFixture.at(10_000)),
            ],
            events: [
                .stub(name: "late", sessionID: sID1, date: TimelineFixture.at(100_002)),
                .stub(name: "early", sessionID: sID1, date: TimelineFixture.at(100_001)),
            ],
            crashes: [
                .stub(name: "late", sessionID: sID1, date: TimelineFixture.at(200_002)),
                .stub(name: "early", sessionID: sID1, date: TimelineFixture.at(200_001)),
            ]
        )

        #expect(rail.installs.map(\.install.installID) == [iID1, iID2])
        #expect(rail.installs[0].launches.map(\.launch.launchID) == [lID1, lID2])
        #expect(rail.installs[0].launches[0].sessions.map(\.session.sessionID) == [sID1, sID2])

        let firstSession = rail.installs[0].launches[0].sessions[0]
        #expect(firstSession.events.map(\.name) == ["early", "late"])
        #expect(firstSession.crashes.map(\.name) == ["early", "late"])
    }

    @Test("Orphans whose parent id does not match are dropped")
    func testOrphans() {
        let deviceID = UUID()
        let sessionID = UUID()

        let rail = Rail(
            device: .stub(deviceID: deviceID),
            installs: [.stub(deviceID: UUID())],
            launches: [],
            sessions: [.stub(sessionID: sessionID, launchID: UUID())],
            events: [.stub(name: "orphan", sessionID: UUID())],
            crashes: [.stub(name: "orphan", sessionID: UUID())]
        )

        #expect(rail.installs.isEmpty)
    }

    @Test("Crashes attach to sessions by sessionID, not launchID")
    func testCrashAttachesBySessionID() {
        let deviceID = UUID()
        let installID = UUID()
        let launchID = UUID()
        let sessionA = UUID()
        let sessionB = UUID()

        let rail = Rail(
            device: .stub(deviceID: deviceID),
            installs: [.stub(installID: installID, deviceID: deviceID)],
            launches: [.stub(launchID: launchID, installID: installID)],
            sessions: [
                .stub(sessionID: sessionA, launchID: launchID, startDate: TimelineFixture.at(0)),
                .stub(sessionID: sessionB, launchID: launchID, startDate: TimelineFixture.at(100)),
            ],
            events: [],
            crashes: [.stub(name: "only-on-B", sessionID: sessionB)]
        )

        let sessions = rail.installs[0].launches[0].sessions
        #expect(sessions[0].crashes.isEmpty)
        #expect(sessions[1].crashes.map(\.name) == ["only-on-B"])
    }
}
