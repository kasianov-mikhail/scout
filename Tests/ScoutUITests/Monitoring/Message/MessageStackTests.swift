//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import ScoutUI

struct MessageStackTests {
    @Test("Pushing below the limit keeps every message in arrival order")
    func pushWithinLimit() {
        var stack: [Message] = []

        stack.push(Message("First", level: .info))
        stack.push(Message("Second", level: .success))

        #expect(stack.map(\.text) == ["First", "Second"])
    }

    @Test("Pushing past the limit keeps only the five most recent messages")
    func pushOverLimit() {
        var stack: [Message] = []

        for index in 1...7 {
            stack.push(Message("Message \(index)", level: .info))
        }

        #expect(stack.map(\.text) == (3...7).map { "Message \($0)" })
    }

    @Test("Dismissing removes only the matching message")
    func dismiss() {
        let kept = Message("Kept", level: .info)
        let dropped = Message("Dropped", level: .error)
        var stack = [kept, dropped]

        stack.dismiss(dropped)

        #expect(stack == [kept])
    }

    @Test("Dismissing leaves same-text messages from other pushes in place")
    func dismissMatchesIdentity() {
        let first = Message("Copied to clipboard", level: .success)
        let second = Message("Copied to clipboard", level: .success)
        var stack = [first, second]

        stack.dismiss(first)

        #expect(stack == [second])
    }
}
