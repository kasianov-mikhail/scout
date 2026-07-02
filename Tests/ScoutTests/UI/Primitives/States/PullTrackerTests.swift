//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct PullTrackerTests {
    private func makeTracker() -> PullTracker {
        PullTracker(threshold: 80, releaseVelocity: 150)
    }

    private func update(_ tracker: inout PullTracker, _ offset: CGFloat, at time: TimeInterval) -> Bool {
        tracker.update(offset: offset, at: time)
    }

    @Test("First sample becomes the baseline and reads as zero")
    func testBaselineCalibration() {
        var tracker = makeTracker()

        #expect(!update(&tracker, 25, at: 0))
        #expect(tracker.offset == 0)

        #expect(!update(&tracker, 75, at: 1))
        #expect(tracker.offset == 50)
    }

    @Test("A fast snap-back through the threshold fires")
    func testFiresOnRelease() {
        var tracker = makeTracker()

        #expect(!update(&tracker, 0, at: 0))
        #expect(!update(&tracker, 100, at: 0.5))
        #expect(update(&tracker, 70, at: 0.51))
    }

    @Test("A slow return through the threshold does not fire")
    func testIgnoresSlowReturn() {
        var tracker = makeTracker()

        #expect(!update(&tracker, 0, at: 0))
        #expect(!update(&tracker, 100, at: 1))
        #expect(!update(&tracker, 79, at: 2))
    }

    @Test("Releasing after a slow return does not fire")
    func testNoFireAfterCancelledPull() {
        var tracker = makeTracker()

        #expect(!update(&tracker, 0, at: 0))
        #expect(!update(&tracker, 100, at: 1))
        #expect(!update(&tracker, 79, at: 2))
        #expect(!update(&tracker, 40, at: 2.01))
        #expect(!update(&tracker, 0, at: 2.02))
    }

    @Test("A pull short of the threshold never fires")
    func testIgnoresShortPull() {
        var tracker = makeTracker()

        #expect(!update(&tracker, 0, at: 0))
        #expect(!update(&tracker, 79, at: 1))
        #expect(!update(&tracker, 0, at: 1.01))
    }

    @Test("The gesture rearms after a cancelled pull")
    func testRearmsAfterCancel() {
        var tracker = makeTracker()

        #expect(!update(&tracker, 0, at: 0))
        #expect(!update(&tracker, 100, at: 1))
        #expect(!update(&tracker, 79, at: 2))

        #expect(!update(&tracker, 100, at: 3))
        #expect(update(&tracker, 70, at: 3.01))
    }

    @Test("Samples sharing a timestamp read as zero velocity")
    func testZeroElapsedIsSafe() {
        var tracker = makeTracker()

        #expect(!update(&tracker, 0, at: 0))
        #expect(!update(&tracker, 100, at: 1))
        #expect(!update(&tracker, 70, at: 1))
    }
}
