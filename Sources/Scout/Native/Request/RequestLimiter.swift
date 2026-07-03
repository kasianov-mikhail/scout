//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import ScoutDB

/// The process-wide limiter that every `CKDatabase.runner` call goes through.
let requestLimiter = RequestLimiter(limit: RequestLimiter.requestLimit)

/// An asynchronous semaphore that caps the number of CloudKit requests in flight.
///
/// Measured in June 2026 (see `benchmarkCloudKitParallelism`): CloudKit query latency
/// scales near-perfectly up to 8 concurrent requests (×4.4 over sequential) and degrades
/// beyond that — 16 in flight doubles batch latency with no throughput gain. The limit
/// keeps Scout inside the well-scaling range no matter how many call sites fan out at
/// once. Re-validate with `verifyParallelismBenchmark` if CloudKit behavior changes.
///
actor RequestLimiter {
    /// The measured CloudKit parallelism ceiling; `verifyParallelismBenchmark` re-checks it.
    static let requestLimit = cloudKitParallelismLimit

    private let limit: Int
    private var running = 0
    private var isDraining = false
    private var waiters: [CheckedContinuation<Void, Never>] = []
    private var drainWaiters: [CheckedContinuation<Void, Never>] = []
    private var drained: CheckedContinuation<Void, Never>?

    init(limit: Int) {
        self.limit = limit
    }

    /// Waits until a request slot is free and claims it; pair with `release()`.
    func acquire() async {
        if !isDraining && running < limit {
            running += 1
            return
        }
        await withCheckedContinuation { continuation in
            waiters.append(continuation)
        }
    }

    /// Frees the slot, handing it to the longest-waiting request if any.
    func release() {
        running -= 1
        if isDraining {
            if running == 0 {
                drained?.resume()
                drained = nil
            }
            return
        }
        resumeWaiters()
    }

    /// Claims every slot at once, giving measurement code exclusive access to CloudKit.
    ///
    /// Waits out in-flight requests and blocks new ones until `releaseAll()`. Drains are
    /// atomic — concurrent callers queue up instead of deadlocking on each other's
    /// partially claimed slots.
    ///
    func acquireAll() async {
        while isDraining {
            await withCheckedContinuation { continuation in
                drainWaiters.append(continuation)
            }
        }
        isDraining = true
        if running > 0 {
            await withCheckedContinuation { continuation in
                drained = continuation
            }
        }
        running = limit
    }

    /// Releases all slots claimed by `acquireAll()`.
    func releaseAll() {
        running = 0
        isDraining = false
        if drainWaiters.count > 0 {
            drainWaiters.removeFirst().resume()
            return
        }
        resumeWaiters()
    }

    private func resumeWaiters() {
        while running < limit, waiters.count > 0 {
            running += 1
            waiters.removeFirst().resume()
        }
    }

    /// Runs `body` while holding one request slot.
    nonisolated func withSlot<R>(body: () async throws -> R) async rethrows -> R {
        try await holding({ await acquire() }, until: { await release() }, body: body)
    }

    /// Runs `body` while holding every slot, giving it exclusive access to CloudKit.
    nonisolated func withAllSlots<R>(body: () async throws -> R) async rethrows -> R {
        try await holding({ await acquireAll() }, until: { await releaseAll() }, body: body)
    }

    nonisolated private func holding<R>(_ claim: () async -> Void, until free: () async -> Void, body: () async throws -> R) async rethrows -> R {
        await claim()
        do {
            let result = try await body()
            await free()
            return result
        } catch {
            await free()
            throw error
        }
    }
}
