//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct ReleaseHealthBuildTests {
    private let range = Date(timeIntervalSince1970: 0)..<Date(timeIntervalSince1970: 700_000)

    @Test("Crashes and sessions join to versions through their launch IDs") func testCrashFreeByVersion() {
        let launchA1 = UUID()
        let launchA2 = UUID()
        let launchB = UUID()

        let installA1 = UUID()
        let installA2 = UUID()
        let installB = UUID()

        let crashedSession = UUID()

        let versions = [
            Version.stub(appVersion: "2.0", buildNumber: "10", launchID: launchA1, date: Date(timeIntervalSince1970: 600_000)),
            Version.stub(appVersion: "2.0", buildNumber: "10", launchID: launchA2, date: Date(timeIntervalSince1970: 550_000)),
            Version.stub(appVersion: "1.0", buildNumber: "5", launchID: launchB, date: Date(timeIntervalSince1970: 100_000)),
        ]

        let sessions = [
            Session.stub(sessionID: crashedSession, launchID: launchA1, installID: installA1),
            Session.stub(launchID: launchA2, installID: installA2),
            Session.stub(launchID: launchB, installID: installB),
        ]

        let crashes = [
            Crash.stub(
                sessionID: crashedSession,
                launchID: launchA1,
                installID: installA1,
                date: Date(timeIntervalSince1970: 500_000)
            )
        ]

        let releases = ReleaseHealth.build(
            versions: versions,
            crashes: crashes,
            sessions: sessions,
            range: range
        )

        #expect(releases.map(\.version) == ["2.0", "1.0"])

        let latest = releases[0]
        #expect(latest.sessions == 2)
        #expect(latest.crashes.count == 1)
        #expect(latest.crashFreeSessions == 0.5)
        #expect(latest.crashFreeUsers == 0.5)
        #expect(abs(latest.adoption - 2.0 / 3.0) < 1e-9)

        let previous = releases[1]
        #expect(previous.sessions == 1)
        #expect(previous.crashes.count == 0)
        #expect(previous.crashFreeSessions == 1)
        #expect(abs(previous.adoption - 1.0 / 3.0) < 1e-9)
    }

    @Test("Crashes and sessions on unknown launches are ignored") func testUnknownLaunchIgnored() {
        let launch = UUID()

        let versions = [Version.stub(appVersion: "3.0", launchID: launch)]
        let sessions = [
            Session.stub(launchID: launch),
            Session.stub(launchID: UUID()),
        ]
        let crashes = [Crash.stub(launchID: UUID())]

        let releases = ReleaseHealth.build(versions: versions, crashes: crashes, sessions: sessions, range: range)

        #expect(releases.count == 1)
        #expect(releases[0].sessions == 1)
        #expect(releases[0].crashes.count == 0)
        #expect(releases[0].crashFreeSessions == 1)
    }

    @Test("No data yields no releases") func testEmpty() {
        let releases = ReleaseHealth.build(versions: [], crashes: [], sessions: [], range: range)
        #expect(releases.isEmpty)
    }
}
