//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import Testing

@testable import Scout

struct RailMergeTests {
    private let baseDate = Date(timeIntervalSince1970: 1_700_000_000)
    private func at(_ offset: TimeInterval) -> Date { baseDate.addingTimeInterval(offset) }

    @Test("Empty merge returns equivalent tree")
    func testEmptyMerge() {
        let rail = DeviceRail.stub(baseDate: baseDate)
        let merged = rail.merged()

        #expect(merged.device.deviceID == rail.device.deviceID)
        #expect(merged.installs.count == rail.installs.count)
        let mergedEvents = merged.installs[0].launches[0].sessions[0].events.map(\.name)
        let originalEvents = rail.installs[0].launches[0].sessions[0].events.map(\.name)
        #expect(mergedEvents == originalEvents)
    }

    @Test("Adds new event to an existing session")
    func testAddsEvent() {
        let rail = DeviceRail.stub(baseDate: baseDate)
        let sessionID = rail.installs[0].launches[0].sessions[0].session.sessionID!

        let merged = rail.merged(events: [.stub(name: "new-event", sessionID: sessionID, date: at(150))])

        let events = merged.installs[0].launches[0].sessions[0].events
        #expect(events.contains { $0.name == "new-event" })
        #expect(events.count == rail.installs[0].launches[0].sessions[0].events.count + 1)
    }

    @Test("Adds new session under an existing launch")
    func testAddsSession() {
        let rail = DeviceRail.stub(baseDate: baseDate)
        let launchID = rail.installs[0].launches[0].launch.launchID!

        let newSession = Session.stub(launchID: launchID, startDate: at(900))
        let merged = rail.merged(sessions: [newSession])

        let sessions = merged.installs[0].launches[0].sessions
        #expect(sessions.contains { $0.session.sessionID == newSession.sessionID })
        #expect(sessions.count == rail.installs[0].launches[0].sessions.count + 1)
    }

    @Test("Adds new install under the device")
    func testAddsInstall() {
        let rail = DeviceRail.stub(baseDate: baseDate)
        let newInstall = Install.stub(deviceID: rail.device.deviceID, date: at(2000))

        let merged = rail.merged(installs: [newInstall])

        #expect(merged.installs.contains { $0.install.installID == newInstall.installID })
        #expect(merged.installs.count == rail.installs.count + 1)
    }

    @Test("Drops new items whose parent is not in the existing tree")
    func testDropsOrphans() {
        let rail = DeviceRail.stub(baseDate: baseDate)
        let merged = rail.merged(events: [.stub(name: "orphan", sessionID: UUID())])

        let allEventNames = merged.installs.flatMap {
            $0.launches.flatMap { $0.sessions.flatMap { $0.events.map(\.name) } }
        }
        #expect(!allEventNames.contains("orphan"))
    }

    @Test("New item with the same id replaces existing")
    func testDedupReplacesExisting() {
        let deviceID = UUID()
        let installID = UUID()
        let launchID = UUID()
        let sessionID = UUID()
        let eventID = CKRecord.ID(recordName: UUID().uuidString)

        let original = DeviceRail.tree(
            devices: [.stub(deviceID: deviceID)],
            installs: [.stub(installID: installID, deviceID: deviceID)],
            launches: [.stub(launchID: launchID, installID: installID)],
            sessions: [.stub(sessionID: sessionID, launchID: launchID)],
            events: [
                Event(
                    name: "old-name", level: nil, date: at(10),
                    paramCount: nil, uuid: nil, id: eventID,
                    installID: nil, sessionID: sessionID
                )
            ],
            crashes: []
        ).first!

        let replacement = Event(
            name: "new-name", level: nil, date: at(10),
            paramCount: nil, uuid: nil, id: eventID,
            installID: nil, sessionID: sessionID
        )
        let merged = original.merged(events: [replacement])

        let events = merged.installs[0].launches[0].sessions[0].events
        #expect(events.count == 1)
        #expect(events[0].name == "new-name")
    }

    @Test("Sort order maintained after merge")
    func testSortMaintained() {
        let rail = DeviceRail.stub(baseDate: baseDate)
        let sessionID = rail.installs[0].launches[0].sessions[0].session.sessionID!
        let originalDates = rail.installs[0].launches[0].sessions[0].events.compactMap(\.date)

        // Insert an event whose date falls between two existing ones.
        let middle = originalDates[0].addingTimeInterval(1)
        let merged = rail.merged(events: [.stub(name: "mid", sessionID: sessionID, date: middle)])

        let dates = merged.installs[0].launches[0].sessions[0].events.compactMap(\.date)
        #expect(dates == dates.sorted())
    }
}
