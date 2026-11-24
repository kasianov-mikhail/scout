//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import ScoutUI

@MainActor
struct AutoRefreshTests {
    @Test func repeatsAfterTheInterval() async {
        let counter = Counter()
        let task = Task {
            await autoRefreshLoop(every: .milliseconds(20)) {
                counter.increment()
            }
        }

        await counter.waitFor(count: 1)
        try? await Task.sleep(for: .milliseconds(200))
        task.cancel()
        await task.value

        #expect(counter.value >= 2)
    }

    @Test func waitsForThePreviousRun() async {
        let gate = Gate()
        let counter = Counter()
        let task = Task {
            await autoRefreshLoop(every: .milliseconds(10)) {
                counter.increment()
                await gate.wait()
            }
        }

        await counter.waitFor(count: 1)
        try? await Task.sleep(for: .milliseconds(60))
        #expect(counter.value == 1)

        gate.open()
        await counter.waitFor(count: 2)
        task.cancel()
        await task.value
    }

    @Test func cancellationStopsTheLoop() async {
        let counter = Counter()
        let task = Task {
            await autoRefreshLoop(every: .milliseconds(10)) {
                counter.increment()
            }
        }

        await counter.waitFor(count: 1)
        task.cancel()
        await task.value

        let stopped = counter.value
        try? await Task.sleep(for: .milliseconds(50))
        #expect(counter.value == stopped)
    }
}

@MainActor
private final class Counter {
    private(set) var value = 0
    private var waiters: [Waiter] = []

    func increment() {
        value += 1
        let ready = waiters.filter { value >= $0.count }
        waiters.removeAll { value >= $0.count }
        ready.forEach { $0.continuation.resume() }
    }

    func waitFor(count: Int) async {
        guard value < count else {
            return
        }
        await withCheckedContinuation { continuation in
            waiters.append(Waiter(count: count, continuation: continuation))
        }
    }
}

private struct Waiter {
    let count: Int
    let continuation: CheckedContinuation<Void, Never>
}
