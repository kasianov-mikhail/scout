//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

@Suite("ScreenStack")
struct ScreenStackTests {
    let home = UUID()
    let feed = UUID()

    @Test("The first screen opens without a previous one")
    func firstScreen() {
        var stack = ScreenStack()

        let changes = stack.show(visitID: home, name: "Home")

        #expect(changes.map(\.summary) == ["open Home after -"])
    }

    @Test("A pushed screen closes the one below and names it as previous")
    func push() throws {
        var stack = ScreenStack()
        let opened = try #require(stack.show(visitID: home, name: "Home").first)

        let changes = stack.show(visitID: feed, name: "Feed")

        #expect(changes.map(\.summary) == ["close", "open Feed after Home"])
        #expect(changes.first?.screenID == opened.screenID)
    }

    @Test("The screen below disappearing after a push changes nothing")
    func lowerScreenDisappears() {
        var stack = ScreenStack()
        _ = stack.show(visitID: home, name: "Home")
        _ = stack.show(visitID: feed, name: "Feed")

        #expect(stack.hide(visitID: home).isEmpty)
    }

    @Test("Dismissing the top screen opens the one below again")
    func dismiss() {
        var stack = ScreenStack()
        _ = stack.show(visitID: home, name: "Home")
        _ = stack.show(visitID: feed, name: "Feed")

        let changes = stack.hide(visitID: feed)

        #expect(changes.map(\.summary) == ["close", "open Home after Feed"])
    }

    @Test("Showing the current screen again changes nothing")
    func repeatedShow() {
        var stack = ScreenStack()
        _ = stack.show(visitID: home, name: "Home")

        #expect(stack.show(visitID: home, name: "Home").isEmpty)
    }

    @Test("The background closes the screen, and the return opens it without a previous one")
    func background() {
        var stack = ScreenStack()
        _ = stack.show(visitID: home, name: "Home")

        #expect(stack.suspend().map(\.summary) == ["close"])
        #expect(stack.show(visitID: feed, name: "Feed").isEmpty)
        #expect(stack.resume().map(\.summary) == ["open Feed after -"])
    }

    @Test("Hiding the last screen closes it")
    func hideLast() {
        var stack = ScreenStack()
        _ = stack.show(visitID: home, name: "Home")

        #expect(stack.hide(visitID: home).map(\.summary) == ["close"])
    }
}

extension ScreenChange {
    fileprivate var summary: String {
        switch self {
        case .open(_, let name, let previous):
            "open \(name) after \(previous ?? "-")"
        case .close:
            "close"
        }
    }

    fileprivate var screenID: UUID {
        switch self {
        case .open(let screenID, _, _), .close(let screenID):
            screenID
        }
    }
}
