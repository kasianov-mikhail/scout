//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Testing

@testable import Scout

struct TimelineExportTests {
    private func uuid(_ prefix: String) -> UUID {
        UUID(uuidString: "\(prefix)-0000-0000-0000-000000000000")!
    }

    @Test("Returns nil when the rail has no installs")
    func testNilWithoutInstalls() {
        let rail = Rail(device: .stub(), installs: [])
        #expect(TimelineExport(rail: rail).text == nil)
    }

    @Test("Renders the rail as a hierarchical Markdown document")
    func testDocument() {
        let session = SessionRoot(
            session: .stub(sessionID: uuid("DDDDDDDD"), startDate: TimelineFixture.at(40), endDate: TimelineFixture.at(400)),
            events: [
                .stub(name: "purchase_completed", date: TimelineFixture.at(160)),
                .stub(name: "app_open", date: TimelineFixture.at(40)),
            ],
            crashes: [.stub(name: "EXC_BAD_ACCESS", date: TimelineFixture.at(100))]
        )
        let launch = LaunchRoot(
            launch: .stub(launchID: uuid("CCCCCCCC"), startDate: TimelineFixture.baseDate),
            sessions: [session]
        )
        let install = InstallRoot(
            install: .stub(installID: uuid("BBBBBBBB"), date: TimelineFixture.baseDate),
            launches: [launch]
        )
        let rail = Rail(device: .stub(deviceID: uuid("AAAAAAAA")), installs: [install])

        #expect(
            TimelineExport(rail: rail).text == """
                # Scout Timeline — Device aaaaaaaa
                1 install · 1 launch · 1 session · 2 events · 1 crash

                ## Install 2023-11-14 (bbbbbbbb)

                ### Launch 2023-11-14 22:13 (cccccccc)

                #### Session 2023-11-14 22:14–22:20 (dddddddd)
                - 2023-11-14T22:14:00Z  app_open
                - 2023-11-14T22:15:00Z  ⚠️ crash: EXC_BAD_ACCESS
                - 2023-11-14T22:16:00Z  purchase_completed
                """
        )
    }

    @Test("Headers omit missing dates and identifiers")
    func testMissingMetadata() {
        let session = SessionRoot(
            session: Session(
                startDate: nil,
                endDate: nil,
                id: "session",
                sessionID: nil,
                launchID: nil,
                installID: nil
            ),
            events: [],
            crashes: []
        )
        let launch = LaunchRoot(
            launch: Launch(
                startDate: nil,
                endDate: nil,
                id: "launch",
                launchID: nil,
                installID: nil
            ),
            sessions: [session]
        )
        let install = InstallRoot(
            install: Install(
                date: nil,
                id: "install",
                installID: nil,
                deviceID: nil
            ),
            launches: [launch]
        )
        let rail = Rail(
            device: Device(date: nil, id: "device", deviceID: nil),
            installs: [install]
        )

        #expect(
            TimelineExport(rail: rail).text == """
                # Scout Timeline
                1 install · 1 launch · 1 session · 0 events

                ## Install

                ### Launch

                #### Session
                """
        )
    }

    @Test("Session ranges spanning days repeat the date in the end bound")
    func testMultiDayRange() {
        let session = SessionRoot(
            session: .stub(sessionID: uuid("DDDDDDDD"), startDate: TimelineFixture.at(40), endDate: TimelineFixture.at(40 + 86_400)),
            events: [],
            crashes: []
        )
        let rail = rail(sessions: [session])

        let text = TimelineExport(rail: rail).text
        #expect(text?.contains("#### Session 2023-11-14 22:14–2023-11-15 22:14 (dddddddd)") == true)
    }

    @Test("Crash rows include the reason when present")
    func testCrashReason() {
        let crash = Crash(
            name: "SIGABRT",
            reason: "unexpectedly found nil",
            stackTrace: [],
            date: TimelineFixture.at(10),
            id: "crash",
            installID: nil,
            launchID: nil,
            sessionID: nil
        )
        let session = SessionRoot(session: .stub(startDate: TimelineFixture.baseDate), events: [], crashes: [crash])
        let rail = rail(sessions: [session])

        let text = TimelineExport(rail: rail).text
        #expect(text?.contains("- 2023-11-14T22:13:30Z  ⚠️ crash: SIGABRT (unexpectedly found nil)") == true)
    }

    @Test("Events without a date are omitted")
    func testUndatedEventsOmitted() {
        let session = SessionRoot(
            session: .stub(startDate: TimelineFixture.baseDate),
            events: [
                .stub(name: "dated", date: TimelineFixture.at(40)),
                .stub(name: "undated", date: nil),
            ],
            crashes: []
        )
        let rail = rail(sessions: [session])

        let text = TimelineExport(rail: rail).text
        #expect(text?.contains("dated") == true)
        #expect(text?.contains("undated") == false)
        #expect(text?.contains("1 event") == true)
    }

    @Test("Sessions render in the tree's chronological order")
    func testSessionsSorted() {
        let deviceID = UUID()
        let installID = UUID()
        let launchID = UUID()

        // `Rail.init` sorts the tree; the export relies on that invariant
        // instead of re-sorting, so feed it unsorted input.
        let rail = Rail(
            device: .stub(deviceID: deviceID),
            installs: [.stub(installID: installID, deviceID: deviceID, date: TimelineFixture.baseDate)],
            launches: [.stub(launchID: launchID, installID: installID, startDate: TimelineFixture.baseDate)],
            sessions: [
                .stub(launchID: launchID, startDate: TimelineFixture.at(2800)),
                .stub(launchID: launchID, startDate: TimelineFixture.at(40)),
            ]
        )

        let text = TimelineExport(rail: rail).text!
        let first = text.range(of: "#### Session 2023-11-14 22:14")
        let second = text.range(of: "#### Session 2023-11-14 23:00")
        #expect(first != nil && second != nil)
        #expect(first!.lowerBound < second!.lowerBound)
    }

    /// Wraps the given sessions in a single-install, single-launch rail.
    private func rail(sessions: [SessionRoot]) -> Rail {
        let launch = LaunchRoot(launch: .stub(startDate: TimelineFixture.baseDate), sessions: sessions)
        let install = InstallRoot(install: .stub(date: TimelineFixture.baseDate), launches: [launch])
        return Rail(device: .stub(), installs: [install])
    }
}
