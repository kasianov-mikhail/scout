//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreGraphics
import Foundation
import Scout
import Testing

@testable import ScoutUI

struct EventScrollAnchorTests {
    @Test func tracksTheTopVisibleRow() {
        let top = Event.sample("top", at: Date())
        let below = Event.sample("below", at: Date())
        var anchor = EventScrollAnchor()

        anchor.track(frames: [
            top.id: CGRect(x: 0, y: -10, width: 100, height: 44),
            below.id: CGRect(x: 0, y: 34, width: 100, height: 44),
        ])

        #expect(anchor.id == top.id)
    }

    @Test func noAnchorAtTheTop() {
        let event = Event.sample("event", at: Date())
        var anchor = EventScrollAnchor()
        anchor.track(frames: [event.id: CGRect(x: 0, y: 10, width: 100, height: 44)])
        #expect(anchor.id == nil)
    }

    @Test func restoresOnlyAnExistingRow() {
        let event = Event.sample("event", at: Date())
        var anchor = EventScrollAnchor()
        anchor.track(frames: [event.id: CGRect(x: 0, y: -10, width: 100, height: 44)])

        #expect(anchor.restoreID(records: [event]) == event.id)
        #expect(anchor.restoreID(records: []) == nil)
    }

    @Test func resetClearsTheAnchor() {
        let event = Event.sample("event", at: Date())
        var anchor = EventScrollAnchor()
        anchor.track(frames: [event.id: CGRect(x: 0, y: -10, width: 100, height: 44)])
        anchor.reset()
        #expect(anchor.id == nil)
    }
}
