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

@Suite("ModelDetail")
struct ModelDetailTests {
    @Test("Keeps only the requested model and sorts its devices by last seen")
    func filtersModel() {
        let activities = [
            DeviceActivity(
                deviceID: UUID().uuidString, model: "iPhone16,1", osVersion: "iOS 17.4",
                lastSeen: Date(timeIntervalSinceNow: -3600), sessions: 10, crashes: 1),
            DeviceActivity(
                deviceID: UUID().uuidString, model: "iPhone16,1", osVersion: "iOS 17.4",
                lastSeen: Date(timeIntervalSinceNow: -60), sessions: 20, crashes: 0),
            DeviceActivity(
                deviceID: UUID().uuidString, model: "iPhone14,5", osVersion: "iOS 17.4", lastSeen: Date(), sessions: 30,
                crashes: 0),
        ]

        let detail = ModelDetail(model: "iPhone16,1", activities: activities)

        #expect(detail.deviceCount == 2)
        #expect(detail.sessionCount == 30)
        #expect(detail.crashCount == 1)
        #expect(detail.devices.first?.sessions == 20)
    }

    @Test("Groups sessions and devices by OS version")
    func osUsage() throws {
        let activities = [
            DeviceActivity(
                deviceID: UUID().uuidString, model: "iPhone16,1", osVersion: "iOS 17.4", lastSeen: Date(), sessions: 75,
                crashes: 0),
            DeviceActivity(
                deviceID: UUID().uuidString, model: "iPhone16,1", osVersion: "iOS 17.4",
                lastSeen: Date(timeIntervalSinceNow: -60), sessions: 0, crashes: 0),
            DeviceActivity(
                deviceID: UUID().uuidString, model: "iPhone16,1", osVersion: "iOS 17.3",
                lastSeen: Date(timeIntervalSinceNow: -120), sessions: 25, crashes: 0),
        ]

        let detail = ModelDetail(model: "iPhone16,1", activities: activities)
        let latest = try #require(detail.osVersions.first)

        #expect(detail.osVersions.count == 2)
        #expect(latest.version == "iOS 17.4")
        #expect(latest.devices == 2)
        #expect(latest.sessions == 75)
        #expect(latest.percentage == 75)
        #expect(detail.osVersions[1].percentage == 25)
    }

    @Test("A model without activities yields an empty detail")
    func emptyDetail() {
        let detail = ModelDetail(model: "iPhone16,1", activities: [])

        #expect(detail.deviceCount == 0)
        #expect(detail.sessionCount == 0)
        #expect(detail.crashCount == 0)
        #expect(detail.maxSessions == 0)
        #expect(detail.osVersions.isEmpty)
    }

    @Test("The unknown model groups devices without a model")
    func unknownModel() {
        let activities = [
            DeviceActivity(
                deviceID: UUID().uuidString, model: nil, osVersion: "iOS 17.4", lastSeen: Date(), sessions: 4,
                crashes: 0)
        ]

        let detail = ModelDetail(model: nil, activities: activities)

        #expect(detail.deviceCount == 1)
        #expect(detail.sessionCount == 4)
    }
}
