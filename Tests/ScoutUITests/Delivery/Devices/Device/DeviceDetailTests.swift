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

@Suite("DeviceDetail")
struct DeviceDetailTests {
    @Test("Keeps the five newest sessions and flags the crashed one")
    func recentSessions() {
        let device = DeviceSummary(
            id: UUID(), model: "iPhone16,1", osVersion: "iOS 17.4", lastSeen: Date(), sessions: 6, crashes: 1)
        let now = Date()
        let sessions = (0..<6).map { index in
            let id = UUID()
            return Session(
                startDate: now.addingTimeInterval(-Double(index) * 3_600),
                endDate: now.addingTimeInterval(-Double(index) * 3_600 + 120),
                id: id.uuidString,
                sessionID: id,
                launchID: nil,
                installID: nil,
                deviceID: device.id,
                osVersion: "iOS 17.4",
                appVersion: "2.4.1"
            )
        }
        let crashed = Crash.sample(
            "Stub", at: now, deviceID: device.id, sessionID: sessions[2].sessionID)

        let detail = DeviceDetail(
            summary: device,
            range: .week,
            sessions: sessions,
            crashes: [crashed],
            hangs: [],
            resources: [],
            installs: [],
            versions: [],
            now: now
        )

        #expect(detail.recentSessions.count == 5)
        #expect(detail.recentSessions.first?.startDate == sessions[0].startDate)
        #expect(detail.recentSessions.filter { $0.crashed }.count == 1)
        #expect(detail.recentSessions.map(\.durationText).allSatisfy { $0 == "2 min" })
        #expect(detail.maxSessionDuration == 120)
        #expect(detail.crashes == 1)
        #expect(detail.medianDuration == 120)
    }

    @Test("Builds seven daily activity points for a week")
    func dailyActivity() {
        let device = DeviceSummary(
            id: UUID(), model: "iPhone16,1", osVersion: "iOS 17.4", lastSeen: Date(), sessions: 0, crashes: 0)
        let now = Date()
        let sessions = [
            Session(
                startDate: now, endDate: nil, id: "1", sessionID: UUID(), launchID: nil, installID: nil,
                deviceID: device.id),
            Session(
                startDate: now.addingDay(-3), endDate: nil, id: "2", sessionID: UUID(), launchID: nil, installID: nil,
                deviceID: device.id),
        ]

        let detail = DeviceDetail(
            summary: device,
            range: .week,
            sessions: sessions,
            crashes: [],
            hangs: [],
            resources: [],
            installs: [],
            versions: [],
            now: now
        )

        #expect(detail.activity.count == 7)
        #expect(detail.activity.last?.count == 1)
        #expect(detail.activeDaysLabel == "2 of 7 days")
        #expect(detail.activityCaption.hasPrefix("Sessions per day"))
    }

    @Test("Counts each incident kind")
    func incidentCounts() {
        let device = DeviceSummary(
            id: UUID(), model: "iPhone16,1", osVersion: "iOS 17.4", lastSeen: Date(), sessions: 0, crashes: 0)
        let now = Date()

        let detail = DeviceDetail(
            summary: device,
            range: .week,
            sessions: [],
            crashes: [Crash.sample("Crash", at: now, deviceID: device.id)],
            hangs: [
                Hang.sample("Hang", duration: 2, at: now, deviceID: device.id),
                Hang.sample("Hang", duration: 3, at: now.addingDay(-1), deviceID: device.id),
            ],
            resources: [ResourceException.sample],
            installs: [],
            versions: [],
            now: now
        )

        #expect(detail.crashes == 1)
        #expect(detail.hangs == 2)
        #expect(detail.resources == 1)
        #expect(detail.recentSessions.isEmpty)
    }
}
