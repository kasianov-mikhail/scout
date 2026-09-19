//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout
@testable import ScoutUI

struct TimelineItemConnectedTests {
    private func makeItem(sessionID: UUID?, active: Set<LegendKind> = [.install, .launch, .session]) -> TimelineItem {
        TimelineItem(
            id: UUID().uuidString,
            name: "e",
            date: TimelineFixture.baseDate,
            active: active,
            installID: UUID(),
            launchID: UUID(),
            sessionID: sessionID
        )
    }

    @Test("Rows in the same group are connected")
    func testSameGroup() {
        let sessionID = UUID()
        let a = makeItem(sessionID: sessionID)
        let b = makeItem(sessionID: sessionID)

        #expect(a.isConnected(other: b, kind: .session))
    }

    @Test("Rows in different groups are not connected")
    func testDifferentGroups() {
        #expect(!makeItem(sessionID: UUID()).isConnected(other: makeItem(sessionID: UUID()), kind: .session))
    }

    @Test("A missing neighbor breaks the rail")
    func testMissingNeighbor() {
        let item = makeItem(sessionID: UUID())

        #expect(!item.isConnected(other: nil, kind: .session))
    }

    @Test("A nil group id breaks the rail even when both rows are active")
    func testNilGroupID() {
        let a = makeItem(sessionID: nil)
        let b = makeItem(sessionID: nil)

        #expect(!a.isConnected(other: b, kind: .session))
    }

    @Test("An inactive kind breaks the rail")
    func testInactiveKind() {
        let sessionID = UUID()
        let a = makeItem(sessionID: sessionID, active: [.install])
        let b = makeItem(sessionID: sessionID)

        #expect(!a.isConnected(other: b, kind: .session))
    }
}
