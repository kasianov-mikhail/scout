//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import ScoutCore
@testable import ScoutTestSupport
@testable import ScoutUI

@MainActor
@Suite("DeviceIncidentsProvider")
struct DeviceIncidentsProviderTests {
    @Test("Fetches only the device's crashes and hangs, newest first")
    func fetchFiltersToDeviceAndSortsNewestFirst() async throws {
        let device = UUID()
        let otherDevice = UUID()
        let oldest = Date(timeIntervalSinceNow: -3600)
        let newest = Date()

        let database = DatabaseStub()
        database.add(
            .crashStub(deviceID: device, date: oldest),
            .crashStub(deviceID: device, date: newest),
            .crashStub(deviceID: otherDevice, date: newest),
            .hangStub(deviceID: device, date: oldest),
            .hangStub(deviceID: device, date: newest),
            .hangStub(deviceID: otherDevice, date: newest)
        )

        let provider = DeviceIncidentsProvider(deviceID: device)
        await provider.fetchIfNeeded(in: database)
        let incidents = try #require(provider.result).get()

        #expect(incidents.crashes.map(\.date) == [newest, oldest])
        #expect(incidents.hangs.map(\.date) == [newest, oldest])
        #expect(incidents.crashes.allSatisfy { $0.deviceID == device })
        #expect(incidents.hangs.allSatisfy { $0.deviceID == device })
    }

    @Test("No crashes or hangs yields empty arrays")
    func fetchWithNoIncidentsYieldsEmptyArrays() async throws {
        let database = DatabaseStub()

        let provider = DeviceIncidentsProvider(deviceID: UUID())
        await provider.fetchIfNeeded(in: database)
        let incidents = try #require(provider.result).get()

        #expect(incidents.crashes.isEmpty)
        #expect(incidents.hangs.isEmpty)
    }
}
