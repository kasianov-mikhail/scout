//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import SwiftUI
import Testing

@testable import ScoutUI
@testable import Support

@MainActor
struct TimelineRowsTests {
    private let deviceID = UUID()
    private let installID = UUID()
    private let launchID = UUID()
    private let sessionID = UUID()

    private func rail(launches: [Launch], sessions: [Session] = [], events: [Event] = []) -> Rail {
        Rail(
            device: .stub(deviceID: deviceID, date: TimelineFixture.baseDate),
            installs: [.stub(installID: installID, deviceID: deviceID, date: TimelineFixture.baseDate)],
            launches: launches,
            sessions: sessions,
            events: events,
            crashes: []
        )
    }

    private func entries(_ rail: Rail, incidents: TimelineIncidents = TimelineIncidents(), focus: TimelineFocus? = nil, reachesStart: Bool = true, reachesEnd: Bool = true) -> [TimelineEntry] {
        TimelineRows(
            rail: rail,
            incidents: incidents,
            focus: focus,
            now: TimelineFixture.at(10_000),
            reachesStart: reachesStart,
            reachesEnd: reachesEnd
        ).entries
    }

    @Test("The head shows the install, the launch and the first session")
    func testHead() {
        let launch = Launch.stub(launchID: launchID, installID: installID, startDate: TimelineFixture.at(10))
        let session = Session.stub(
            sessionID: sessionID, launchID: launchID, installID: installID,
            startDate: TimelineFixture.at(20), endDate: TimelineFixture.at(120))
        let rows = entries(rail(launches: [launch], sessions: [session], events: [.stub(name: "e", sessionID: sessionID, date: TimelineFixture.at(30))]))

        #expect(rows.map(\.kind) == [.install, .launch, .fork, .event])
    }

    @Test("A crash closes its session with a red merge row")
    func testCrashMerge() {
        let launch = Launch.stub(launchID: launchID, installID: installID, startDate: TimelineFixture.at(10))
        let session = Session.stub(
            sessionID: sessionID, launchID: launchID, installID: installID, startDate: TimelineFixture.at(20))
        let crash = Crash.stub(name: "SIGABRT", sessionID: sessionID, date: TimelineFixture.at(100))
        let incidents = TimelineIncidents(crashes: [crash])
        let rows = entries(rail(launches: [launch], sessions: [session], events: [.stub(name: "e", sessionID: sessionID, date: TimelineFixture.at(30))]), incidents: incidents)

        let crashRow = rows.first { $0.kind == .crash }
        let mergeRow = rows.first { $0.kind == .merge }

        #expect(crashRow?.session?.split?.color == .timelineCrash)
        #expect(crashRow?.session?.split?.y == 22)
        #expect(mergeRow?.title.text == "App crashed")
        #expect(mergeRow?.session == nil)
    }

    @Test("A crash before the session ends keeps the session rail green")
    func testCrashContinues() {
        let launch = Launch.stub(launchID: launchID, installID: installID, startDate: TimelineFixture.at(10))
        let session = Session.stub(
            sessionID: sessionID, launchID: launchID, installID: installID, startDate: TimelineFixture.at(20))
        let crash = Crash.stub(name: "SIGABRT", sessionID: sessionID, date: TimelineFixture.at(50))
        let incidents = TimelineIncidents(crashes: [crash])
        let events: [Event] = [
            .stub(name: "before", sessionID: sessionID, date: TimelineFixture.at(30)),
            .stub(name: "after", sessionID: sessionID, date: TimelineFixture.at(60)),
        ]
        let rows = entries(rail(launches: [launch], sessions: [session], events: events), incidents: incidents)

        let crashRow = rows.first { $0.kind == .crash }

        #expect(crashRow?.session?.split == nil)
        #expect(!rows.contains { $0.kind == .merge && $0.title.text == "App crashed" })
    }

    @Test("A focus on a crash adds the chip and the tint")
    func testCrashFocus() {
        let launch = Launch.stub(launchID: launchID, installID: installID, startDate: TimelineFixture.at(10))
        let session = Session.stub(
            sessionID: sessionID, launchID: launchID, installID: installID, startDate: TimelineFixture.at(20))
        let crash = Crash.stub(name: "SIGABRT", sessionID: sessionID, date: TimelineFixture.at(100))
        let incidents = TimelineIncidents(crashes: [crash])
        let rows = entries(
            rail(launches: [launch], sessions: [session], events: [.stub(name: "e", sessionID: sessionID, date: TimelineFixture.at(30))]),
            incidents: incidents,
            focus: TimelineFocus(crash: crash)
        )

        let row = rows.first { $0.id == crash.id }
        #expect(row?.chip == "This crash")
        #expect(row?.tint != nil)
    }

    @Test("A long idle time inserts a gap row")
    func testGap() {
        let first = Launch.stub(launchID: launchID, installID: installID, startDate: TimelineFixture.at(10))
        let secondID = UUID()
        let second = Launch.stub(
            launchID: secondID, installID: installID, startDate: TimelineFixture.at(10 + 3 * 3_600))
        let session = Session.stub(
            sessionID: sessionID, launchID: launchID, installID: installID,
            startDate: TimelineFixture.at(20), endDate: TimelineFixture.at(200))
        let rows = entries(rail(launches: [first, second], sessions: [session]))

        #expect(rows.contains { $0.kind == .gap && $0.title.text == "3 h" })
    }

    @Test("A session without events renders a loop row")
    func testLoop() {
        let launch = Launch.stub(launchID: launchID, installID: installID, startDate: TimelineFixture.at(10))
        let session = Session.stub(
            sessionID: sessionID, launchID: launchID, installID: installID,
            startDate: TimelineFixture.at(20), endDate: TimelineFixture.at(60))
        let rows = entries(rail(launches: [launch], sessions: [session]))

        #expect(rows.contains { $0.kind == .loop && $0.subtitle?.text == "no events · 40s" })
    }

    @Test("A launch with no end that is not live ends as unknown")
    func testUnknown() {
        let first = Launch.stub(launchID: launchID, installID: installID, startDate: TimelineFixture.at(10))
        let second = Launch.stub(launchID: UUID(), installID: installID, startDate: TimelineFixture.at(3_600))
        let session = Session.stub(
            sessionID: sessionID, launchID: launchID, installID: installID,
            startDate: TimelineFixture.at(20), endDate: TimelineFixture.at(200))
        let rows = entries(rail(launches: [first, second], sessions: [session]))

        #expect(rows.contains { $0.kind == .unknown && $0.title.text == "App end not recorded" })
    }

    @Test("A launch with no sessions and an end shows the close row")
    func testClose() {
        let launch = Launch.stub(
            launchID: launchID, installID: installID, startDate: TimelineFixture.at(10), endDate: TimelineFixture.at(100))
        let rows = entries(rail(launches: [launch]))

        #expect(rows.contains { $0.kind == .close && $0.title.text == "App closed" })
        #expect(rows.contains { $0.kind == .launch && $0.subtitle?.text == "No sessions" })
    }

    @Test("An open last session is live")
    func testLiveSession() {
        let launch = Launch.stub(launchID: launchID, installID: installID, startDate: TimelineFixture.at(9_000))
        let session = Session.stub(
            sessionID: sessionID, launchID: launchID, installID: installID, startDate: TimelineFixture.at(9_100))
        let rows = entries(rail(launches: [launch], sessions: [session], events: [.stub(name: "e", sessionID: sessionID, date: TimelineFixture.at(9_200))]))

        #expect(rows.contains { $0.kind == .fork && $0.subtitle?.text.hasPrefix("live · ") == true })
        #expect(!rows.contains { $0.kind == .unknown })
    }

    @Test("A launch outside the loaded range waits until the lane reaches it")
    func testUnloadedLaunch() {
        let launch = Launch.stub(launchID: launchID, installID: installID, startDate: TimelineFixture.at(10))
        let session = Session.stub(
            sessionID: sessionID, launchID: launchID, installID: installID,
            startDate: TimelineFixture.at(20), endDate: TimelineFixture.at(200))
        let later = Launch.stub(launchID: UUID(), installID: installID, startDate: TimelineFixture.at(3_600))
        let rows = entries(rail(launches: [launch, later], sessions: [session]), reachesEnd: false)

        #expect(rows.count(where: { $0.kind == .launch }) == 1)
    }
}
