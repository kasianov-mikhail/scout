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
struct TimelineProviderTests {
    private let baseDate = Date(timeIntervalSince1970: 1_700_000_000)
    private func at(_ offset: TimeInterval) -> Date { baseDate.addingTimeInterval(offset) }

    private let deviceID = UUID()
    private let installID = UUID()
    private let launchID = UUID()
    private let sessionID = UUID()

    private func makeDatabase() -> DatabaseStub {
        let database = DatabaseStub()
        database.add(
            .deviceStub(deviceID: deviceID, date: baseDate),
            .installStub(installID: installID, deviceID: deviceID, date: baseDate),
            .launchStub(launchID: launchID, installID: installID, deviceID: deviceID, startDate: at(10)),
            .sessionStub(sessionID: sessionID, launchID: launchID, installID: installID, startDate: at(20)),
            .eventStub(name: "e", sessionID: sessionID, date: at(30))
        )
        return database
    }

    private func start(_ provider: TimelineProvider, database: DatabaseStub, anchorEvent: Event?) async {
        let feed = TimelineFeed(deviceID: deviceID, database: database)
        await provider.start(feed: feed, anchorEvent: anchorEvent, eventName: nil)
    }

    @Test("Publishes a result without an anchor event")
    func testNoAnchorPublishes() async throws {
        let provider = TimelineProvider()
        await start(provider, database: makeDatabase(), anchorEvent: nil)

        let rail = try #require(provider.result).get()
        #expect(rail.installs.map(\.install.installID) == [installID])
        #expect(provider.items.map(\.name) == ["e"])
    }

    @Test("Publishes a result when the anchor's install is not in the rail")
    func testMissingAnchorInstallPublishes() async throws {
        let provider = TimelineProvider()
        let anchor = Event.stub(name: "a", installID: UUID(), date: at(30))
        await start(provider, database: makeDatabase(), anchorEvent: anchor)

        let rail = try #require(provider.result).get()
        #expect(rail.installs.map(\.install.installID) == [installID])
    }

    @Test("Anchored start seeds the timeline around the anchor")
    func testAnchoredStart() async throws {
        let provider = TimelineProvider()
        let anchor = Event.stub(name: "e", sessionID: sessionID, installID: installID, date: at(30))
        await start(provider, database: makeDatabase(), anchorEvent: anchor)

        let rail = try #require(provider.result).get()
        let sessions = rail.installs.flatMap { $0.launches.flatMap(\.sessions) }
        #expect(sessions.map(\.session.sessionID) == [sessionID])
        #expect(provider.items.map(\.name) == ["e"])
    }

    @Test("Caches the export text alongside the published result")
    func testExportTextCached() async throws {
        let provider = TimelineProvider()
        await start(provider, database: makeDatabase(), anchorEvent: nil)

        #expect(provider.exportText?.contains("- 2023-11-14T22:13:50Z  e") == true)
    }

    @Test("A backend with no records publishes an empty result")
    func testEmptyBackendPublishesNoItems() async throws {
        let provider = TimelineProvider()
        let feed = TimelineFeed(deviceID: deviceID, database: DatabaseStub())

        await provider.start(feed: feed, anchorEvent: nil, eventName: nil)

        _ = try #require(provider.result).get()
        #expect(provider.items.count == 0)
    }
}
