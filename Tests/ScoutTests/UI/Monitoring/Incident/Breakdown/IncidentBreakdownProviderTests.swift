//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Testing

@testable import Scout

@MainActor
@Suite("IncidentBreakdownProvider")
struct IncidentBreakdownProviderTests {
    @Test("Groups device models for the requested device IDs")
    func fetchGroupsDeviceModels() async throws {
        let deviceA = UUID()
        let deviceB = UUID()
        let other = UUID()

        let database = DatabaseStub()
        database.add(
            .deviceStub(deviceID: deviceA, date: Date(), model: "iPhone15,3"),
            .deviceStub(deviceID: deviceB, date: Date(), model: "iPhone14,2"),
            .deviceStub(deviceID: other, date: Date(), model: "iPad13,1")
        )

        let provider = IncidentBreakdownProvider(deviceIDs: [deviceA, deviceB], sessionIDs: [])
        await provider.fetchIfNeeded(in: database)
        let breakdown = try #require(try? provider.result?.get())

        #expect(Set(breakdown.devices.map(\.label)) == ["iPhone15,3", "iPhone14,2"])
    }

    @Test("Groups OS versions for the requested session IDs")
    func fetchGroupsOSVersions() async throws {
        let sessionA = UUID()
        let sessionB = UUID()
        let other = UUID()

        let database = DatabaseStub()
        database.add(
            .sessionStub(sessionID: sessionA, launchID: UUID(), installID: UUID(), startDate: Date(), osVersion: "iOS 17.4"),
            .sessionStub(sessionID: sessionB, launchID: UUID(), installID: UUID(), startDate: Date(), osVersion: "iOS 17.4"),
            .sessionStub(sessionID: other, launchID: UUID(), installID: UUID(), startDate: Date(), osVersion: "iOS 16.7")
        )

        let provider = IncidentBreakdownProvider(deviceIDs: [], sessionIDs: [sessionA, sessionB])
        await provider.fetchIfNeeded(in: database)
        let breakdown = try #require(try? provider.result?.get())

        #expect(breakdown.osVersions.map(\.label) == ["iOS 17.4"])
        #expect(breakdown.osVersions.first?.count == 2)
    }

    @Test("Skips fetching when there are no IDs to resolve")
    func fetchSkipsEmptyIDs() async throws {
        let database = DatabaseStub()

        let provider = IncidentBreakdownProvider(deviceIDs: [], sessionIDs: [])
        await provider.fetchIfNeeded(in: database)
        let breakdown = try #require(try? provider.result?.get())

        #expect(breakdown.devices.isEmpty)
        #expect(breakdown.osVersions.isEmpty)
    }
}
