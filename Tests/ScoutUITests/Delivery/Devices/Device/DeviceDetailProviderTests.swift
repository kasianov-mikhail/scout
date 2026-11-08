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
@testable import Support

@MainActor
@Suite("DeviceDetailProvider")
struct DeviceDetailProviderTests {
    @Test("Fetches only this device's records inside the period")
    func fetchFiltersDeviceAndRange() async throws {
        let device = DeviceSummary(
            id: UUID(), model: "iPhone16,1", osVersion: "iOS 17.4", lastSeen: Date(), sessions: 2, crashes: 1)
        let other = UUID()
        let now = Date()
        let sessionID = UUID()
        let installID = UUID()

        let database = DatabaseStub()
        var version = Version(
            appVersion: "2.4.1", buildNumber: "241", launchID: UUID(), installID: installID, date: now,
            id: UUID().uuidString
        ).record
        version["device_id"] = device.id.uuidString

        database.add(
            .sessionStub(
                sessionID: sessionID, launchID: UUID(), installID: installID, startDate: now, endDate: now.addingTimeInterval(180),
                osVersion: "iOS 17.4", appVersion: "2.4.1", deviceID: device.id),
            .sessionStub(
                sessionID: UUID(), launchID: UUID(), installID: installID, startDate: now.addingDay(-10),
                osVersion: "iOS 17.3", appVersion: "2.4.0", deviceID: device.id),
            .sessionStub(
                sessionID: UUID(), launchID: UUID(), installID: UUID(), startDate: now, osVersion: "iOS 17.4",
                deviceID: other),
            .crashStub(deviceID: device.id, date: now),
            .crashStub(deviceID: device.id, date: now.addingDay(-10)),
            .crashStub(deviceID: other, date: now),
            .hangStub(deviceID: device.id, date: now),
            .installStub(installID: installID, deviceID: device.id, date: now.addingDay(-20)),
            version
        )

        let provider = DeviceDetailProvider(device: device)
        await provider.fetchIfNeeded(in: database)
        let detail = try #require(provider.result).get()

        #expect(detail.recentSessions.count == 1)
        #expect(detail.recentSessions.first?.appVersion == "2.4.1")
        #expect(detail.recentSessions.first?.durationText == "3 min")
        #expect(detail.crashes == 1)
        #expect(detail.hangs == 1)
        #expect(detail.resources == 0)
        #expect(detail.activity.last?.count == 1)
        #expect(detail.history.contains { $0.title == "Updated to" } == false)
        #expect(detail.history.contains { $0.title == "First seen with" })
    }

    @Test("No records yields an empty detail")
    func emptyDetail() async throws {
        let device = DeviceSummary(
            id: UUID(), model: "iPhone16,1", osVersion: "iOS 17.4", lastSeen: Date(), sessions: 0, crashes: 0)

        let provider = DeviceDetailProvider(device: device)
        await provider.fetchIfNeeded(in: DatabaseStub())
        let detail = try #require(provider.result).get()

        #expect(detail.crashes == 0)
        #expect(detail.hangs == 0)
        #expect(detail.resources == 0)
        #expect(detail.recentSessions.isEmpty)
        #expect(detail.history.isEmpty)
    }
}
