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

@Suite("DeviceModelSummary")
struct DeviceModelSummaryTests {
    @Test("Groups devices by model and sums their sessions and crashes")
    func groupsByModel() throws {
        let date = Date()
        let activities = [
            DeviceActivity(
                deviceID: UUID().uuidString, model: "iPhone16,1", osVersion: "iOS 17.4", lastSeen: date, sessions: 200,
                crashes: 2),
            DeviceActivity(
                deviceID: UUID().uuidString, model: "iPhone16,1", osVersion: "iOS 17.3", lastSeen: date, sessions: 100,
                crashes: 1),
        ]

        let summaries = [DeviceModelSummary](activities: activities)
        let summary = try #require(summaries.first)

        #expect(summaries.count == 1)
        #expect(summary.model == "iPhone16,1")
        #expect(summary.name == "iPhone 15 Pro")
        #expect(summary.devices == 2)
        #expect(summary.sessions == 300)
        #expect(summary.crashes == 3)
        #expect(summary.osLabel == "iOS 17.3–17.4")
    }

    @Test("Sorts models by sessions, then by name")
    func sortsBySessions() {
        let date = Date()

        let activities = [
            DeviceActivity(
                deviceID: UUID().uuidString, model: "iPhone14,5", osVersion: "iOS 17.4", lastSeen: date, sessions: 100,
                crashes: 0),
            DeviceActivity(
                deviceID: UUID().uuidString, model: "iPhone16,1", osVersion: "iOS 17.4", lastSeen: date, sessions: 200,
                crashes: 0),
            DeviceActivity(
                deviceID: UUID().uuidString, model: "iPad13,1", osVersion: "iPadOS 17.4", lastSeen: date, sessions: 100,
                crashes: 0),
        ]

        let summaries = [DeviceModelSummary](activities: activities)

        #expect(summaries.map(\.name) == ["iPhone 15 Pro", "iPad Air (4th generation)", "iPhone 13"])
    }

    @Test("Devices without a model group under Unknown")
    func unknownModel() throws {
        let summary = try #require(
            [DeviceModelSummary](
                activities: [
                    DeviceActivity(
                        deviceID: UUID().uuidString, model: nil, osVersion: "iOS 17.4", lastSeen: Date(), sessions: 1,
                        crashes: 0)
                ]
            ).first
        )

        #expect(summary.model == nil)
        #expect(summary.id == "")
        #expect(summary.name == "Unknown")
        #expect(summary.osLabel == "iOS 17.4")
    }
}
