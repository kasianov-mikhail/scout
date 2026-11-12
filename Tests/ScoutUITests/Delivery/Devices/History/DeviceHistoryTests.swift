//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import Testing

@testable import ScoutUI

@Suite("DeviceHistoryEvent")
struct DeviceHistoryTests {
    @Test("Builds installs, updates and OS changes newest first")
    func buildsHistory() {
        let deviceID = UUID()
        let firstInstallID = UUID()
        let secondInstallID = UUID()
        let day = Date(timeIntervalSince1970: 1_700_000_000)

        let installs = [
            Install(date: day, id: "install-1", installID: firstInstallID, deviceID: deviceID),
            Install(date: day.addingDay(9), id: "install-2", installID: secondInstallID, deviceID: deviceID),
        ]
        let versions = [
            Version(
                appVersion: "2.3.9", buildNumber: "239", launchID: UUID(), installID: firstInstallID,
                date: day.addingDay(1), id: "version-1"),
            Version(
                appVersion: "2.4.0", buildNumber: "240", launchID: UUID(), installID: firstInstallID,
                date: day.addingDay(4), id: "version-2"),
            Version(
                appVersion: "2.4.1", buildNumber: "241", launchID: UUID(), installID: secondInstallID,
                date: day.addingDay(9), id: "version-3"),
        ]
        let sessions = [
            Session(
                startDate: day.addingDay(1), endDate: nil, id: "session-1", sessionID: UUID(), launchID: nil,
                installID: firstInstallID, osVersion: "iOS 17.3"),
            Session(
                startDate: day.addingDay(6), endDate: nil, id: "session-2", sessionID: UUID(), launchID: nil,
                installID: firstInstallID, osVersion: "iOS 17.4"),
        ]

        let events = [DeviceHistoryEvent](installs: installs, versions: versions, sessions: sessions)

        #expect(
            events.map(\.title) == [
                "Reinstalled with", "iOS 17.3 → 17.4", "Updated to", "First seen with",
            ])
        #expect(events.map(\.version) == ["2.4.1", nil, "2.4.0", "2.3.9"])
    }

    @Test("Builds a first seen event from versions when installs are missing")
    func versionOnlyHistory() {
        let day = Date(timeIntervalSince1970: 1_700_000_000)
        let versions = [
            Version(appVersion: "1.0", buildNumber: "1", launchID: nil, date: day, id: "version-1"),
            Version(appVersion: "1.1", buildNumber: "2", launchID: nil, date: day.addingDay(3), id: "version-2"),
        ]

        let events = [DeviceHistoryEvent](installs: [], versions: versions, sessions: [])

        #expect(events.map(\.title) == ["Updated to", "First seen with"])
        #expect(events.map(\.version) == ["1.1", "1.0"])
    }

    @Test("Keeps only OS changes, not every session")
    func osChanges() {
        let day = Date(timeIntervalSince1970: 1_700_000_000)
        let sessions = [
            Session(
                startDate: day, endDate: nil, id: "1", sessionID: UUID(), launchID: nil, installID: nil,
                osVersion: "iOS 17.3"),
            Session(
                startDate: day.addingDay(1), endDate: nil, id: "2", sessionID: UUID(), launchID: nil, installID: nil,
                osVersion: "iOS 17.3"),
            Session(
                startDate: day.addingDay(2), endDate: nil, id: "3", sessionID: UUID(), launchID: nil, installID: nil,
                osVersion: "iOS 17.4"),
        ]

        let events = [DeviceHistoryEvent](installs: [], versions: [], sessions: sessions)

        #expect(events.count == 1)
        #expect(events.first?.title == "iOS 17.3 → 17.4")
    }

    @Test("An empty device has no history")
    func emptyHistory() {
        #expect([DeviceHistoryEvent](installs: [], versions: [], sessions: []).isEmpty)
    }
}
