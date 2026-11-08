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
@Suite("DeviceModelsProvider")
struct DeviceModelsProviderTests {
    @Test("Fetches devices and groups them by model")
    func fetchGroupsModels() async throws {
        let first = UUID()
        let second = UUID()
        let date = Date()

        let database = DatabaseStub()
        database.add(
            .deviceStub(deviceID: first, date: date, model: "iPhone16,1"),
            .deviceStub(deviceID: second, date: date, model: "iPhone16,1"),
            .sessionStub(
                sessionID: UUID(), launchID: UUID(), installID: UUID(), startDate: date, osVersion: "iOS 17.4",
                deviceID: first),
            .sessionStub(
                sessionID: UUID(), launchID: UUID(), installID: UUID(), startDate: date, osVersion: "iOS 17.3",
                deviceID: second)
        )

        let provider = DeviceModelsProvider()
        await provider.fetchIfNeeded(in: database)
        let models = try #require(provider.result).get()
        let model = try #require(models.first)

        #expect(models.count == 1)
        #expect(model.model == "iPhone16,1")
        #expect(model.devices == 2)
        #expect(model.sessions == 2)
        #expect(model.osLabel == "iOS 17.3–17.4")
    }

    @Test("A period change drops sessions outside the new range")
    func rangeFiltersSessions() async throws {
        let device = UUID()
        let recent = Date()
        let stale = Date().addingDay(-10)

        let database = DatabaseStub()
        database.add(
            .deviceStub(deviceID: device, date: recent, model: "iPhone16,1"),
            .sessionStub(
                sessionID: UUID(), launchID: UUID(), installID: UUID(), startDate: recent, osVersion: "iOS 17.4",
                deviceID: device),
            .sessionStub(
                sessionID: UUID(), launchID: UUID(), installID: UUID(), startDate: stale, osVersion: "iOS 17.4",
                deviceID: device)
        )

        let provider = DeviceModelsProvider()
        await provider.fetchIfNeeded(in: database)
        let models = try #require(provider.result).get()

        #expect(models.first?.sessions == 1)
    }

    @Test("No devices yields no models")
    func emptyDatabase() async throws {
        let provider = DeviceModelsProvider()
        await provider.fetchIfNeeded(in: DatabaseStub())
        let models = try #require(provider.result).get()

        #expect(models.isEmpty)
    }
}
