//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import ScoutUI

struct PullStateTests {
    @Test("Rest is idle, hidden and without inset") func rest() {
        let state = PullState(threshold: 60)

        #expect(state.phase == .idle)
        #expect(state.isVisible == false)
        #expect(state.inset == 0)
        #expect(state.progress == 0)
    }

    @Test("Pulling short of the threshold shows progress and does not trigger") func shortPull() {
        var state = PullState(threshold: 60)
        let triggered = state.update(pull: 30)

        #expect(triggered == false)
        #expect(state.phase == .idle)
        #expect(state.isVisible)
        #expect(state.progress == 0.5)
        #expect(state.inset == 0)
    }

    @Test("Returning short of the threshold keeps showing progress") func shortReturn() {
        var state = PullState(threshold: 60)
        _ = state.update(pull: 45)
        let triggered = state.update(pull: 15)

        #expect(triggered == false)
        #expect(state.phase == .idle)
        #expect(state.progress == 0.25)
    }

    @Test("Reaching the threshold triggers once and holds the inset") func trigger() {
        var state = PullState(threshold: 60)
        let triggered = state.update(pull: 60)

        #expect(triggered)
        #expect(state.phase == .refreshing)
        #expect(state.progress == nil)
        #expect(state.inset == 60)
        #expect(state.isVisible)
        #expect(state.isArmed == false)

        let deeper = state.update(pull: 90)
        let settled = state.update(pull: 60)

        #expect(deeper == false)
        #expect(settled == false)
        #expect(state.phase == .refreshing)
    }

    @Test("Progress is capped at one") func cappedProgress() {
        var state = PullState(threshold: 60)
        _ = state.update(pull: 90)

        #expect(state.progress == nil)

        state = PullState(threshold: 60)
        _ = state.update(pull: 59)

        #expect(state.progress == 59.0 / 60.0)
    }

    @Test("Finishing retracts without progress and stays visible until settled") func finish() {
        var state = PullState(threshold: 60)
        _ = state.update(pull: 60)
        state.finish()

        #expect(state.phase == .retracting)
        #expect(state.inset == 0)
        #expect(state.progress == nil)
        #expect(state.isVisible)
        #expect(state.ringScale == 0)
        #expect(state.ringOffset(size: 22) == -41)

        let rested = state.update(pull: 0)

        #expect(rested == false)
        #expect(state.phase == .retracting)
        #expect(state.isVisible)

        state.settle()

        #expect(state.phase == .idle)
        #expect(state.isVisible == false)
        #expect(state.ringScale == 1)
    }

    @Test("Settling outside of retracting is a no-op") func settleIdle() {
        var state = PullState(threshold: 60)
        _ = state.update(pull: 60)
        state.settle()

        #expect(state.phase == .refreshing)
    }

    @Test("Finishing while idle is a no-op") func finishIdle() {
        var state = PullState(threshold: 60)
        _ = state.update(pull: 20)
        state.finish()

        #expect(state.phase == .idle)
        #expect(state.progress == 20.0 / 60.0)
    }

    @Test("Retracting does not re-trigger until it has settled and rested") func noRetrigger() {
        var state = PullState(threshold: 60)
        _ = state.update(pull: 60)
        state.finish()
        let early = state.update(pull: 80)

        #expect(early == false)
        #expect(state.phase == .retracting)

        state.settle()
        let held = state.update(pull: 80)

        #expect(held == false)
        #expect(state.phase == .idle)
        #expect(state.isArmed == false)
        #expect(state.isVisible == false)

        _ = state.update(pull: 0)
        let again = state.update(pull: 60)

        #expect(again)
    }

    @Test("A bounce that is not a drag never triggers") func bounce() {
        var state = PullState(threshold: 60)
        let bounced = state.update(pull: 90, dragging: false)

        #expect(bounced == false)
        #expect(state.phase == .idle)
        #expect(state.isVisible)
        #expect(state.progress == 1)
    }

    @Test("Trigger without a pull refreshes once and re-arms only at rest") func triggerDirectly() {
        var state = PullState(threshold: 60)
        let first = state.trigger()
        let second = state.trigger()

        #expect(first)
        #expect(second == false)
        #expect(state.phase == .refreshing)

        state.finish()
        state.settle()
        let third = state.trigger()

        #expect(third == false)

        _ = state.update(pull: 0)
        let fourth = state.trigger()

        #expect(fourth)
    }

    @Test("Negative offsets clamp to rest") func negative() {
        var state = PullState(threshold: 60)
        _ = state.update(pull: -20)

        #expect(state.pull == 0)
        #expect(state.isVisible == false)
    }

    @Test("Ring emerges from under the bar into the centre of the held gap") func ringOffset() {
        var state = PullState(threshold: 60)

        #expect(state.ringOffset(size: 22) == -41)

        _ = state.update(pull: 30)
        #expect(state.ringOffset(size: 22) == -11)

        _ = state.update(pull: 60)
        #expect(state.ringOffset(size: 22) == 19)

        _ = state.update(pull: 100)
        #expect(state.ringOffset(size: 22) == 59)
    }

    @Test("Sub-point residue after settling reads as rest") func slack() {
        var state = PullState(threshold: 60)
        _ = state.update(pull: 0.67)

        #expect(state.pull == 0)
        #expect(state.isVisible == false)

        _ = state.update(pull: 1)
        #expect(state.pull == 1)
    }
}
