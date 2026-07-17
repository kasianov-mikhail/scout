//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import SwiftUI
import Testing

@testable import Scout
@testable import ScoutUI

@Suite("SessionInfo")
struct SessionInfoTests {
    @Test("version combines app version and build number")
    func versionWithBuild() {
        let info = SessionInfo(appVersion: "2.3.1", buildNumber: "412")
        #expect(info.version == "v2.3.1 (412)")
    }

    @Test("version omits the build number when it is missing")
    func versionWithoutBuild() {
        let info = SessionInfo(appVersion: "2.3.1")
        #expect(info.version == "v2.3.1")
    }

    @Test("version is nil without an app version")
    func versionWithoutAppVersion() {
        #expect(SessionInfo().version == nil)
    }

    @Test(
        "duration formats seconds, minutes, and hours",
        arguments: [
            (30, "30s"),
            (720, "12m"),
            (3600, "1h"),
            (3720, "1h 2m"),
        ])
    func durationFormats(seconds: Int, expected: String) {
        let start = Date()
        let info = SessionInfo(startDate: start, endDate: start.addingTimeInterval(TimeInterval(seconds)))
        #expect(info.duration == expected)
    }

    @Test("duration is nil for open or inverted ranges")
    func durationMissing() {
        let start = Date()
        #expect(SessionInfo(startDate: start, endDate: nil).duration == nil)
        #expect(SessionInfo(startDate: nil, endDate: start).duration == nil)
        #expect(SessionInfo(startDate: start, endDate: start.addingTimeInterval(-10)).duration == nil)
    }

    @Test("channel styling reflects the distribution channel")
    func channelStyling() {
        #expect(SessionInfo(channel: "App Store").channelColor == .green)
        #expect(SessionInfo(channel: "TestFlight").channelColor == .orange)
        #expect(SessionInfo(channel: "Debug").channelColor == .gray)
        #expect(SessionInfo(channel: "TestFlight").channelIcon == "airplane")
    }
}
