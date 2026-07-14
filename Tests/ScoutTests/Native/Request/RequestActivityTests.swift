//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ScoutDB
import Testing

@testable import Scout

@Suite("RequestActivity")
@MainActor struct RequestActivityTests {
    @Test("Starts empty")
    func testStartsEmpty() {
        let activity = RequestActivity(limit: 8)

        #expect(activity.running == 0)
        #expect(activity.fraction == 0)
        #expect(!activity.isSaturated)
    }

    @Test("Mirrors the counts the stream publishes")
    func testMirrorsStream() async {
        let activity = RequestActivity(limit: 8)
        let (stream, continuation) = AsyncStream.makeStream(of: Int.self)

        let tracking = Task { await activity.track(stream) }
        continuation.yield(3)
        while activity.running != 3 {
            await Task.yield()
        }

        #expect(activity.fraction == 0.375)
        #expect(!activity.isSaturated)

        continuation.finish()
        await tracking.value
    }

    @Test("Saturates at the limit")
    func testSaturatesAtLimit() async {
        let activity = RequestActivity(limit: 8)
        let (stream, continuation) = AsyncStream.makeStream(of: Int.self)

        let tracking = Task { await activity.track(stream) }
        continuation.yield(8)
        while activity.running != 8 {
            await Task.yield()
        }

        #expect(activity.isSaturated)
        #expect(activity.fraction == 1)

        continuation.finish()
        await tracking.value
    }

    @Test("Clamps the fraction to a full arc above the limit")
    func testClampsFraction() async {
        let activity = RequestActivity(limit: 8)
        let (stream, continuation) = AsyncStream.makeStream(of: Int.self)

        let tracking = Task { await activity.track(stream) }
        continuation.yield(10)
        while activity.running != 10 {
            await Task.yield()
        }

        #expect(activity.fraction == 1)
        #expect(activity.isSaturated)

        continuation.finish()
        await tracking.value
    }

    @Test("A zero limit leaves the arc empty")
    func testZeroLimit() {
        #expect(RequestActivity(limit: 0).fraction == 0)
    }

    @Test("Tracks the limit ScoutDB throttles to")
    func testSharedLimit() {
        #expect(RequestActivity.shared.limit == cloudKitParallelismLimit)
    }
}
