//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import ScoutCore
@testable import ScoutUI

@Suite("DeviceSummary")
struct DeviceSummaryTests {
    @Test("Aggregates sessions and crashes per device, using the latest session for OS version and last seen")
    func summariesAggregatePerDevice() throws {
        let deviceID = UUID()
        let older = Date(timeIntervalSinceNow: -3600)
        let newer = Date()

        let summaries = DeviceSummary.summaries(
            devices: [.deviceStub(deviceID: deviceID, date: older, model: "iPhone15,3")],
            sessions: [
                .sessionStub(
                    sessionID: UUID(), launchID: UUID(), installID: UUID(), startDate: older, osVersion: "iOS 17.3",
                    deviceID: deviceID),
                .sessionStub(
                    sessionID: UUID(), launchID: UUID(), installID: UUID(), startDate: newer, osVersion: "iOS 17.4",
                    deviceID: deviceID),
            ],
            crashes: [.crashStub(deviceID: deviceID, date: newer)]
        )

        let summary = try #require(summaries.first)
        #expect(summaries.count == 1)
        #expect(summary.model == "iPhone15,3")
        #expect(summary.osVersion == "iOS 17.4")
        #expect(summary.lastSeen == newer)
        #expect(summary.sessions == 2)
        #expect(summary.crashes == 1)
    }

    @Test("Excludes devices with no recorded sessions")
    func summariesExcludeSessionlessDevices() {
        let deviceID = UUID()

        let summaries = DeviceSummary.summaries(
            devices: [.deviceStub(deviceID: deviceID, date: Date(), model: "iPhone15,3")],
            sessions: [],
            crashes: []
        )

        #expect(summaries.isEmpty)
    }

    @Test("Keeps devices with no model, naming them Unknown")
    func summariesKeepModellessDevices() throws {
        let deviceID = UUID()

        let summaries = DeviceSummary.summaries(
            devices: [.deviceStub(deviceID: deviceID, date: Date(), model: nil)],
            sessions: [
                .sessionStub(
                    sessionID: UUID(), launchID: UUID(), installID: UUID(), startDate: Date(), deviceID: deviceID)
            ],
            crashes: []
        )

        let summary = try #require(summaries.first)
        #expect(summaries.count == 1)
        #expect(summary.model == nil)
        #expect(summary.modelName == "Unknown")
    }

    @Test("Keeps devices independent")
    func summariesKeepDevicesIndependent() {
        let deviceA = UUID()
        let deviceB = UUID()

        let summaries = DeviceSummary.summaries(
            devices: [
                .deviceStub(deviceID: deviceA, date: Date(), model: "iPhone15,3"),
                .deviceStub(deviceID: deviceB, date: Date(), model: "iPad13,1"),
            ],
            sessions: [
                .sessionStub(
                    sessionID: UUID(), launchID: UUID(), installID: UUID(), startDate: Date(), deviceID: deviceA),
                .sessionStub(
                    sessionID: UUID(), launchID: UUID(), installID: UUID(), startDate: Date(), deviceID: deviceB),
            ],
            crashes: [.crashStub(deviceID: deviceA, date: Date())]
        )

        let byID = Dictionary(uniqueKeysWithValues: summaries.map { ($0.id, $0) })
        #expect(byID[deviceA]?.crashes == 1)
        #expect(byID[deviceB]?.crashes == 0)
    }
}
