//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

@MainActor
@Suite("DevicesProvider")
struct DevicesProviderTests {
    @Test("Fetches every device and aggregates its sessions and crashes")
    func fetchBuildsSummariesForAllDevices() async throws {
        let deviceA = UUID()
        let deviceB = UUID()
        let date = Date()

        let database = DatabaseStub()
        database.add(
            .deviceStub(deviceID: deviceA, date: date, model: "iPhone15,3"),
            .deviceStub(deviceID: deviceB, date: date, model: "iPad13,1"),
            .sessionStub(sessionID: UUID(), launchID: UUID(), installID: UUID(), startDate: date, osVersion: "iOS 17.4", deviceID: deviceA),
            .sessionStub(sessionID: UUID(), launchID: UUID(), installID: UUID(), startDate: date, osVersion: "iOS 17.2", deviceID: deviceB),
            .crashStub(deviceID: deviceA, date: date)
        )

        let provider = DevicesProvider()
        await provider.fetchIfNeeded(in: database)
        let summaries = try #require(provider.result).get()

        #expect(Set(summaries.map(\.model)) == ["iPhone15,3", "iPad13,1"])
        #expect(summaries.first { $0.model == "iPhone15,3" }?.crashes == 1)
        #expect(summaries.first { $0.model == "iPad13,1" }?.crashes == 0)
    }

    @Test("No devices yields no summaries")
    func fetchEmptyDatabaseYieldsNoSummaries() async throws {
        let database = DatabaseStub()

        let provider = DevicesProvider()
        await provider.fetchIfNeeded(in: database)
        let summaries = try #require(provider.result).get()

        #expect(summaries.isEmpty)
    }
}
