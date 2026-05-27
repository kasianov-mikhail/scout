//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import Testing

@testable import Scout

struct RailTreeTests {
    private let baseDate = Date(timeIntervalSince1970: 1_700_000_000)
    private func at(_ offset: TimeInterval) -> Date { baseDate.addingTimeInterval(offset) }

    @Test("Empty input returns no rails")
    func testEmpty() {
        let rails = DeviceRail.tree(
            devices: [], installs: [], launches: [], sessions: [], events: [], crashes: []
        )
        #expect(rails.isEmpty)
    }

    @Test("Builds the full tree linking children to their parents")
    func testFullTree() {
        let deviceID = UUID()
        let installID = UUID()
        let launchID = UUID()
        let sessionID = UUID()

        let rails = DeviceRail.tree(
            devices: [.stub(deviceID: deviceID)],
            installs: [.stub(installID: installID, deviceID: deviceID)],
            launches: [.stub(launchID: launchID, installID: installID)],
            sessions: [.stub(sessionID: sessionID, launchID: launchID)],
            events: [.stub(name: "e1", sessionID: sessionID)],
            crashes: [.stub(name: "c1", sessionID: sessionID)]
        )

        #expect(rails.count == 1)
        let session = rails[0].installs[0].launches[0].sessions[0]
        #expect(session.events.map(\.name) == ["e1"])
        #expect(session.crashes.map(\.name) == ["c1"])
    }

    @Test("Sorts every level by date ascending")
    func testSortingAtAllLevels() {
        let dID1 = UUID(), dID2 = UUID()
        let iID1 = UUID(), iID2 = UUID()
        let lID1 = UUID(), lID2 = UUID()
        let sID1 = UUID(), sID2 = UUID()

        let rails = DeviceRail.tree(
            devices: [
                .stub(deviceID: dID2, date: at(20)),
                .stub(deviceID: dID1, date: at(10)),
            ],
            installs: [
                .stub(installID: iID2, deviceID: dID1, date: at(200)),
                .stub(installID: iID1, deviceID: dID1, date: at(100)),
            ],
            launches: [
                .stub(launchID: lID2, installID: iID1, startDate: at(2000)),
                .stub(launchID: lID1, installID: iID1, startDate: at(1000)),
            ],
            sessions: [
                .stub(sessionID: sID2, launchID: lID1, startDate: at(20_000)),
                .stub(sessionID: sID1, launchID: lID1, startDate: at(10_000)),
            ],
            events: [
                .stub(name: "late", sessionID: sID1, date: at(100_002)),
                .stub(name: "early", sessionID: sID1, date: at(100_001)),
            ],
            crashes: [
                .stub(name: "late", sessionID: sID1, date: at(200_002)),
                .stub(name: "early", sessionID: sID1, date: at(200_001)),
            ]
        )

        #expect(rails.map(\.device.deviceID) == [dID1, dID2])
        #expect(rails[0].installs.map(\.install.installID) == [iID1, iID2])
        #expect(rails[0].installs[0].launches.map(\.launch.launchID) == [lID1, lID2])
        #expect(rails[0].installs[0].launches[0].sessions.map(\.session.sessionID) == [sID1, sID2])

        let firstSession = rails[0].installs[0].launches[0].sessions[0]
        #expect(firstSession.events.map(\.name) == ["early", "late"])
        #expect(firstSession.crashes.map(\.name) == ["early", "late"])
    }

    @Test("Orphans whose parent id does not match are dropped")
    func testOrphans() {
        let deviceID = UUID()
        let sessionID = UUID()

        let rails = DeviceRail.tree(
            devices: [.stub(deviceID: deviceID)],
            installs: [.stub(deviceID: UUID())],
            launches: [],
            sessions: [.stub(sessionID: sessionID, launchID: UUID())],
            events: [.stub(name: "orphan", sessionID: UUID())],
            crashes: [.stub(name: "orphan", sessionID: UUID())]
        )

        #expect(rails.count == 1)
        #expect(rails[0].installs.isEmpty)
    }

    @Test("Crashes attach to sessions by sessionID, not launchID")
    func testCrashAttachesBySessionID() {
        let deviceID = UUID()
        let installID = UUID()
        let launchID = UUID()
        let sessionA = UUID()
        let sessionB = UUID()

        let rails = DeviceRail.tree(
            devices: [.stub(deviceID: deviceID)],
            installs: [.stub(installID: installID, deviceID: deviceID)],
            launches: [.stub(launchID: launchID, installID: installID)],
            sessions: [
                .stub(sessionID: sessionA, launchID: launchID, startDate: at(0)),
                .stub(sessionID: sessionB, launchID: launchID, startDate: at(100)),
            ],
            events: [],
            crashes: [.stub(name: "only-on-B", sessionID: sessionB)]
        )

        let sessions = rails[0].installs[0].launches[0].sessions
        #expect(sessions[0].crashes.isEmpty)
        #expect(sessions[1].crashes.map(\.name) == ["only-on-B"])
    }

    @Test("Multiple devices each get their own subtree")
    func testMultipleDevices() {
        let dID1 = UUID(), dID2 = UUID()
        let iID1 = UUID(), iID2 = UUID()

        let rails = DeviceRail.tree(
            devices: [
                .stub(deviceID: dID1, date: at(0)),
                .stub(deviceID: dID2, date: at(10)),
            ],
            installs: [
                .stub(installID: iID1, deviceID: dID1),
                .stub(installID: iID2, deviceID: dID2),
            ],
            launches: [], sessions: [], events: [], crashes: []
        )

        #expect(rails.count == 2)
        #expect(rails[0].installs.map(\.install.installID) == [iID1])
        #expect(rails[1].installs.map(\.install.installID) == [iID2])
    }
}
