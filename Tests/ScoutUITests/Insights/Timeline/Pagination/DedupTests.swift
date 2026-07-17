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

struct DedupTests {
    private struct Item: Identifiable {
        let id: String
        let tag: String
    }

    private func item(_ name: String, tag: String = "") -> Item {
        Item(id: name, tag: tag)
    }

    @Test("New items come first, then old items")
    func testOrdering() {
        let result = dedup(
            new: [item("a"), item("b")],
            old: [item("c"), item("d")]
        )
        #expect(result.map(\.id) == ["a", "b", "c", "d"])
    }

    @Test("New wins on id collision and the old duplicate is dropped")
    func testNewWinsOnCollision() {
        let result = dedup(
            new: [item("a", tag: "new")],
            old: [item("a", tag: "old"), item("b", tag: "old")]
        )
        #expect(result.map(\.id) == ["a", "b"])
        #expect(result.first?.tag == "new")
    }

    @Test("Duplicates within the new array are removed, keeping the first")
    func testDedupWithinNew() {
        let result = dedup(
            new: [item("a", tag: "first"), item("a", tag: "second")],
            old: []
        )
        #expect(result.map(\.id) == ["a"])
        #expect(result.first?.tag == "first")
    }

    @Test("Empty inputs produce an empty result")
    func testEmpty() {
        let result: [Item] = dedup(new: [], old: [])
        #expect(result.isEmpty)
    }
}
