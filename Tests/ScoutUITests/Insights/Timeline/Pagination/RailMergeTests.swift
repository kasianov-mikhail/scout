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

struct RailMergeTests {
    @Test("Empty merge returns equivalent tree")
    func testEmptyMerge() {
        let rail = Rail.stub(baseDate: TimelineFixture.baseDate)
        let merged = rail.merged(sessions: [], events: [])

        #expect(merged.device.deviceID == rail.device.deviceID)
        #expect(merged.installs.count == rail.installs.count)
        let mergedEvents = merged.installs[0].launches[0].sessions[0].events.map(\.name)
        let originalEvents = rail.installs[0].launches[0].sessions[0].events.map(\.name)
        #expect(mergedEvents == originalEvents)
    }

    @Test("Adds new event to an existing session")
    func testAddsEvent() {
        let rail = Rail.stub(baseDate: TimelineFixture.baseDate)
        let sessionID = rail.installs[0].launches[0].sessions[0].session.sessionID!

        let merged = rail.merged(
            sessions: [],
            events: [.stub(name: "new-event", sessionID: sessionID, date: TimelineFixture.at(150))]
        )

        let events = merged.installs[0].launches[0].sessions[0].events
        #expect(events.contains { $0.name == "new-event" })
        #expect(events.count == rail.installs[0].launches[0].sessions[0].events.count + 1)
    }

    @Test("Adds new session under an existing launch")
    func testAddsSession() {
        let rail = Rail.stub(baseDate: TimelineFixture.baseDate)
        let launchID = rail.installs[0].launches[0].launch.launchID!

        let newSession = Session.stub(launchID: launchID, startDate: TimelineFixture.at(900))
        let merged = rail.merged(sessions: [newSession], events: [])

        let sessions = merged.installs[0].launches[0].sessions
        #expect(sessions.contains { $0.session.sessionID == newSession.sessionID })
        #expect(sessions.count == rail.installs[0].launches[0].sessions.count + 1)
    }

    @Test("Drops new items whose parent is not in the existing tree")
    func testDropsOrphans() {
        let rail = Rail.stub(baseDate: TimelineFixture.baseDate)
        let merged = rail.merged(
            sessions: [],
            events: [.stub(name: "orphan", sessionID: UUID())]
        )

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
        let eventID = UUID().uuidString

        let original = Rail(
            device: .stub(deviceID: deviceID),
            installs: [.stub(installID: installID, deviceID: deviceID)],
            launches: [.stub(launchID: launchID, installID: installID)],
            sessions: [.stub(sessionID: sessionID, launchID: launchID)],
            events: [
                Event(
                    name: "old-name", level: nil, date: TimelineFixture.at(10),
                    paramCount: nil, uuid: nil, id: eventID,
                    installID: nil, sessionID: sessionID, deviceID: nil
                )
            ],
            crashes: []
        )

        let replacement = Event(
            name: "new-name", level: nil, date: TimelineFixture.at(10),
            paramCount: nil, uuid: nil, id: eventID,
            installID: nil, sessionID: sessionID, deviceID: nil
        )
        let merged = original.merged(sessions: [], events: [replacement])

        let events = merged.installs[0].launches[0].sessions[0].events
        #expect(events.count == 1)
        #expect(events[0].name == "new-name")
    }

    @Test("Sort order maintained after merge")
    func testSortMaintained() {
        let rail = Rail.stub(baseDate: TimelineFixture.baseDate)
        let sessionID = rail.installs[0].launches[0].sessions[0].session.sessionID!
        let originalDates = rail.installs[0].launches[0].sessions[0].events.compactMap(\.date)

        // Insert an event whose date falls between two existing ones.
        let middle = originalDates[0].addingTimeInterval(1)
        let merged = rail.merged(
            sessions: [],
            events: [.stub(name: "mid", sessionID: sessionID, date: middle)]
        )

        let dates = merged.installs[0].launches[0].sessions[0].events.compactMap(\.date)
        #expect(dates == dates.sorted())
    }
}
