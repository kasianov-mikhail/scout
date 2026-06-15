//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import Scout

@Suite("RequestLimiter")
struct RequestLimiterTests {
    @Test("Acquires up to the limit without suspending")
    func testAcquiresUpToLimit() async {
        let limiter = RequestLimiter(limit: 3)

        // Would hang here if the limiter blocked before reaching its limit.
        for _ in 0..<3 {
            await limiter.acquire()
        }

        await limiter.releaseAll()
    }

    @Test("Never exceeds the limit under contention")
    func testCapsConcurrency() async {
        let limiter = RequestLimiter(limit: 3)
        let tracker = Tracker()

        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<20 {
                group.addTask {
                    await limiter.acquire()
                    await tracker.enter()
                    try? await Task.sleep(for: .milliseconds(5))
                    await tracker.exit()
                    await limiter.release()
                }
            }
        }

        #expect(await tracker.maxConcurrent <= 3)
        #expect(await tracker.total == 20)
    }

    @Test("Release hands the slot to a waiter")
    func testWaiterResumes() async {
        let limiter = RequestLimiter(limit: 1)
        await limiter.acquire()

        let waiter = Task {
            await limiter.acquire()
            return true
        }

        try? await Task.sleep(for: .milliseconds(50))
        await limiter.release()

        #expect(await waiter.value)
        await limiter.release()
    }

    @Test("acquireAll blocks new requests until releaseAll")
    func testAcquireAllBlocksUntilReleaseAll() async {
        let limiter = RequestLimiter(limit: 2)
        await limiter.acquireAll()

        let entered = Box(false)
        let waiter = Task {
            await limiter.acquire()
            entered.value = true
            await limiter.release()
        }

        try? await Task.sleep(for: .milliseconds(50))
        #expect(!entered.value)

        await limiter.releaseAll()
        await waiter.value

        #expect(entered.value)
    }

    @Test("Concurrent acquireAll calls serialize instead of deadlocking")
    func testConcurrentAcquireAllSerializes() async {
        let limiter = RequestLimiter(limit: 4)
        await limiter.acquire()

        let drains = [
            Task {
                await limiter.withAllSlots { true }
            },
            Task {
                await limiter.withAllSlots { true }
            },
        ]

        // Both drains are now waiting for the held slot; with per-slot
        // acquisition they would deadlock on each other's partial claims.
        try? await Task.sleep(for: .milliseconds(50))
        await limiter.release()

        for drain in drains {
            #expect(await drain.value)
        }
    }
}

private actor Tracker {
    private var current = 0

    var maxConcurrent = 0
    var total = 0

    func enter() {
        current += 1
        total += 1
        maxConcurrent = max(maxConcurrent, current)
    }

    func exit() {
        current -= 1
    }
}
