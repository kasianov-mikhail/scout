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
@Suite("ModelDetailProvider")
struct ModelDetailProviderTests {
    @Test("Fetches only the requested model")
    func fetchFiltersModel() async throws {
        let first = UUID()
        let second = UUID()
        let date = Date()

        let database = DatabaseStub()
        database.add(
            .deviceStub(deviceID: first, date: date, model: "iPhone16,1"),
            .deviceStub(deviceID: second, date: date, model: "iPhone14,5"),
            .sessionStub(
                sessionID: UUID(), launchID: UUID(), installID: UUID(), startDate: date, osVersion: "iOS 17.4",
                deviceID: first),
            .sessionStub(
                sessionID: UUID(), launchID: UUID(), installID: UUID(), startDate: date, osVersion: "iOS 17.3",
                deviceID: second)
        )

        let provider = ModelDetailProvider(model: "iPhone16,1")
        await provider.fetchIfNeeded(in: database)
        let detail = try #require(provider.result).get()

        #expect(provider.modelName == "iPhone 15 Pro")
        #expect(detail.deviceCount == 1)
        #expect(detail.osVersions.map(\.version) == ["iOS 17.4"])
        #expect(detail.osVersions.first?.percentage == 100)
    }

    @Test("The unknown model has no name")
    func unknownModel() async throws {
        let device = UUID()
        let database = DatabaseStub()
        database.add(
            .deviceStub(deviceID: device, date: Date(), model: nil),
            .sessionStub(
                sessionID: UUID(), launchID: UUID(), installID: UUID(), startDate: Date(), osVersion: "iOS 17.4",
                deviceID: device)
        )

        let provider = ModelDetailProvider(model: nil)
        await provider.fetchIfNeeded(in: database)
        let detail = try #require(provider.result).get()

        #expect(provider.modelName == "Unknown")
        #expect(detail.deviceCount == 1)
    }
}
