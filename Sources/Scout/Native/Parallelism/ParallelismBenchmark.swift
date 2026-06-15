//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//
// Maintenance tooling for `RequestLimiter.requestLimit`. Both functions talk to
// CloudKit directly, bypassing the limiter, so concurrency levels above the
// configured limit are actually exercised. Not used in production flows.
//

import CloudKit
import Foundation

/// Measures how CloudKit query latency scales with the number of in-flight requests.
///
/// Runs a warm-up request first, then for each concurrency level in `counts` executes
/// that many identical queries in parallel, `rounds` times. Prints the batch wall-clock
/// time, the effective per-request time, and throttle errors (`serviceUnavailable` /
/// `requestRateLimited`) if they occur. With perfect parallelism the batch time stays
/// flat as the level grows; the level where it starts climbing is the practical ceiling.
///
/// Holds every `RequestLimiter` slot for the duration, so regular Scout traffic neither
/// skews the measurements nor competes with them — library requests queue up and resume
/// once the sweep is done.
///
/// June 2026 baseline: 1 → 409 ms, 2 → 562 ms, 4 → 652 ms, 8 → 751 ms, 16 → 1406 ms,
/// no throttling — the ceiling `RequestLimiter.requestLimit` is based on.
///
public func benchmarkCloudKitParallelism(container: CKContainer, recordType: String = "Event", counts: [Int] = [1, 2, 4, 8, 16], rounds: Int = 2) async {
    let counts = counts.filter { $0 > 0 }

    print("[CKBench] concurrency sweep \(counts), \(rounds) round(s) each, record type \(recordType)")

    await requestLimiter.withAllSlots {
        await runSweep(container.publicCloudDatabase, recordType: recordType, counts: counts, rounds: rounds)
    }
}

private func runSweep(_ database: CKDatabase, recordType: String, counts: [Int], rounds: Int) async {
    do {
        let warmup = try await rawBatch(database, recordType: recordType, count: 1)
        print("[CKBench] warm-up: \(warmup.wholeMilliseconds) ms")
    } catch {
        print("[CKBench] warm-up failed: \(describe(error))")
        return
    }

    var summary: [(count: Int, average: Int)] = []

    for count in counts {
        var durations: [Duration] = []
        for round in 1...rounds {
            do {
                let duration = try await rawBatch(database, recordType: recordType, count: count)
                durations.append(duration)
                print("[CKBench] \(count) in flight, round \(round): \(duration.wholeMilliseconds) ms")
            } catch {
                print("[CKBench] \(count) in flight, round \(round) FAILED: \(describe(error))")
            }
        }
        if durations.count > 0 {
            let batch = average(durations).wholeMilliseconds
            summary.append((count: count, average: batch))
            print("[CKBench] \(count) in flight: avg \(batch) ms per batch, \(batch / count) ms effective per request")
        }
    }

    guard summary.count > 0 else {
        print("[CKBench] no successful batches — see errors above")
        return
    }

    print("[CKBench] RESULT (count → batch ms → effective ms/request):")
    for entry in summary {
        print("[CKBench]   \(entry.count) → \(entry.average) ms → \(entry.average / entry.count) ms")
    }
}

/// Re-validates that `RequestLimiter.requestLimit` still matches CloudKit's behavior.
///
/// Compares the latency of a single request against a batch of `requestLimit` parallel
/// requests and a batch of twice that. Returns `true` when the limit still looks right:
/// the batch at the limit stays within ×3 of a single request and nothing gets throttled.
/// Prints a FAIL with lowering advice when scaling broke down, and a NOTE with raising
/// advice when twice the limit also scales cleanly.
///
/// CloudKit's server-side behavior can change without notice, so run this occasionally —
/// from a nightly performance job, or manually in a debug build after iOS/CloudKit
/// updates. Costs about `3 × requestLimit + 3` requests per run. Holds every
/// `RequestLimiter` slot for the duration, so regular Scout traffic neither skews the
/// measurements nor competes with them — library requests queue up and resume after.
///
@discardableResult public func verifyParallelismBenchmark(container: CKContainer, recordType: String = "Event") async -> Bool {
    print("[CKVerify] checking that \(RequestLimiter.requestLimit) in-flight CloudKit requests is still the right limit")

    return await requestLimiter.withAllSlots {
        await runVerification(container.publicCloudDatabase, recordType: recordType)
    }
}

private func runVerification(_ database: CKDatabase, recordType: String) async -> Bool {
    let limit = RequestLimiter.requestLimit

    do {
        try await rawRead(database, recordType: recordType)

        let single = try await rawBatch(database, recordType: recordType, count: 1, rounds: 2)
        let atLimit = try await rawBatch(database, recordType: recordType, count: limit, rounds: 2)
        print("[CKVerify] 1 in flight: \(single.wholeMilliseconds) ms, \(limit) in flight: \(atLimit.wholeMilliseconds) ms")

        guard atLimit < single * 3 else {
            let factor = String(format: "%.1f", Double(atLimit.wholeMilliseconds) / Double(single.wholeMilliseconds))
            print(
                "[CKVerify] FAIL: \(limit) parallel requests cost ×\(factor) of a single one — "
                    + "scaling degraded, consider lowering RequestLimiter.requestLimit "
                    + "(run benchmarkCloudKitParallelism for the full picture)")
            return false
        }

        let beyond = try await rawBatch(database, recordType: recordType, count: limit * 2)
        print("[CKVerify] \(limit * 2) in flight: \(beyond.wholeMilliseconds) ms")

        if beyond < atLimit * 3 / 2 {
            print(
                "[CKVerify] NOTE: \(limit * 2) in flight still scales cleanly — "
                    + "consider raising RequestLimiter.requestLimit "
                    + "(run benchmarkCloudKitParallelism for the full picture)")
        } else {
            print("[CKVerify] OK: scaling stops past \(limit) in flight, limit confirmed")
        }
        return true
    } catch {
        print(
            "[CKVerify] FAIL: \(describe(error)) — a throttle error here means CloudKit "
                + "no longer tolerates \(RequestLimiter.requestLimit * 2) in-flight requests; "
                + "consider lowering RequestLimiter.requestLimit")
        return false
    }
}

private let resultsLimit = 20

private func makeQuery(_ recordType: String) -> CKQuery {
    let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
    query.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
    return query
}

/// A single query against CloudKit, bypassing `RequestLimiter` (but with the same
/// operation configuration as `CKDatabase.runner`).
private func rawRead(_ database: CKDatabase, recordType: String) async throws {
    _ = try await database.configuredWith(configuration: .scout) { database in
        try await database.records(
            matching: makeQuery(recordType),
            desiredKeys: [],
            resultsLimit: resultsLimit
        )
    }
}

private func rawBatch(_ database: CKDatabase, recordType: String, count: Int, rounds: Int = 1) async throws -> Duration {
    var durations: [Duration] = []
    for _ in 0..<rounds {
        let duration = try await measure {
            try await withThrowingTaskGroup(of: Void.self) { group in
                for _ in 0..<count {
                    group.addTask {
                        try await rawRead(database, recordType: recordType)
                    }
                }
                try await group.waitForAll()
            }
        }
        durations.append(duration)
    }
    return average(durations)
}

private func measure(_ body: () async throws -> Void) async rethrows -> Duration {
    try await ContinuousClock().measure {
        try await body()
    }
}

private func average(_ durations: [Duration]) -> Duration {
    durations.reduce(.zero, +) / durations.count
}

extension Duration {
    fileprivate var wholeMilliseconds: Int {
        Int(self / .milliseconds(1))
    }
}

private func describe(_ error: Error) -> String {
    guard let ckError = error as? CKError else {
        return String(describing: error)
    }
    let retryAfter = ckError.retryAfterSeconds.map { ", retry after \($0)s" } ?? ""
    return "CKError \(ckError.code.rawValue): \(ckError.localizedDescription)\(retryAfter)"
}
