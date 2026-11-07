//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import ScoutUI

@Suite("SessionInfo")
struct SessionInfoTests {
    private let start = Date(timeIntervalSince1970: 1_761_403_200)

    @Test("version combines app version and build number")
    func versionWithBuild() {
        let info = SessionInfo(appVersion: "2.3.1", buildNumber: "412")
        #expect(info.version == "2.3.1 (412)")
    }

    @Test("version omits the build number when it is missing")
    func versionWithoutBuild() {
        let info = SessionInfo(appVersion: "2.3.1")
        #expect(info.version == "2.3.1")
    }

    @Test("version is nil without an app version")
    func versionWithoutAppVersion() {
        #expect(SessionInfo().version == nil)
    }

    @Test(
        "duration formats seconds, minutes, and hours",
        arguments: [
            (30, "30 s"),
            (720, "12 min"),
            (3600, "1 h"),
            (3720, "1 h 2 min"),
            (4332, "1 h 12 min 12 s"),
        ])
    func durationFormats(seconds: Int, expected: String) {
        let info = SessionInfo(startDate: start, endDate: start.addingTimeInterval(TimeInterval(seconds)))
        #expect(info.duration == expected)
    }

    @Test("duration is nil for open or inverted ranges")
    func durationMissing() {
        #expect(SessionInfo(startDate: start, endDate: nil).duration == nil)
        #expect(SessionInfo(startDate: nil, endDate: start).duration == nil)
        #expect(SessionInfo(startDate: start, endDate: start.addingTimeInterval(-10)).duration == nil)
        #expect(SessionInfo(startDate: start, endDate: nil, launchOpen: true).duration == nil)
    }

    @Test("summary shows the duration, day, and time range")
    func summary() {
        let info = SessionInfo(startDate: start, endDate: start.addingTimeInterval(732))
        #expect(info.summary == "12 min 12 s · Sat, Oct 25 · 14:40 – 14:52")
    }

    @Test("summary ends the time range with now while live")
    func liveSummary() {
        let info = SessionInfo(startDate: start, launchOpen: true)
        #expect(info.isLive)
        #expect(info.summary == "Sat, Oct 25 · 14:40 – now")
    }

    @Test("a session is live only without an end date and with an open launch")
    func liveState() {
        #expect(SessionInfo(startDate: start, launchOpen: true).isLive)
        #expect(!SessionInfo(startDate: start, launchOpen: false).isLive)
        #expect(!SessionInfo(startDate: start, endDate: start.addingTimeInterval(10), launchOpen: true).isLive)
    }
}
