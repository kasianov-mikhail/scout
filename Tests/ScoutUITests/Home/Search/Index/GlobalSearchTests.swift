//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout
@testable import ScoutUI

@MainActor
struct GlobalSearchTests {
    @Test("Providers load at the same time") func concurrentLoad() async {
        let tracker = ConcurrencyTracker()
        let providers: [any Provider] = [
            ProviderStub(outcome: .success(1), tracker: tracker),
            ProviderStub(outcome: .success(2), tracker: tracker),
            ProviderStub(outcome: .success(3), tracker: tracker),
        ]

        await providers.fetchIfNeeded(in: DatabaseStub())

        #expect(tracker.peak == 3)
    }

    @Test("A failed provider leaves the others loaded") func partialFailure() async {
        let tracker = ConcurrencyTracker()
        let failing = ProviderStub(outcome: .failure(URLError(.timedOut)), tracker: tracker)
        let loading = ProviderStub(outcome: .success(1), tracker: tracker)

        await [failing, loading].fetchIfNeeded(in: DatabaseStub())

        #expect(failing.error != nil)
        #expect(loading.value == 1)
    }

    @Test("fetchIfNeeded skips loaded providers") func skipsLoaded() async {
        let tracker = ConcurrencyTracker()
        let loaded = ProviderStub(outcome: .success(2), tracker: tracker)
        loaded.result = .success(1)

        await [loaded].fetchIfNeeded(in: DatabaseStub())

        #expect(loaded.fetchCount == 0)
        #expect(loaded.value == 1)
    }

    @Test("fetchIfFailed reloads only failed providers") func reloadsFailed() async {
        let tracker = ConcurrencyTracker()
        let failed = ProviderStub(outcome: .success(1), tracker: tracker)
        failed.result = .failure(URLError(.timedOut))
        let loaded = ProviderStub(outcome: .success(2), tracker: tracker)
        loaded.result = .success(3)

        await [failed, loaded].fetchIfFailed(in: DatabaseStub())

        #expect(failed.value == 1)
        #expect(loaded.fetchCount == 0)
    }
}

@MainActor
private final class ConcurrencyTracker {
    private var running = 0
    private(set) var peak = 0

    func enter() {
        running += 1
        peak = max(peak, running)
    }

    func leave() {
        running -= 1
    }
}

@MainActor
private final class ProviderStub: ObservableObject, Provider {
    @Published var result: ProviderResult<Int>?

    let outcome: ProviderResult<Int>
    let tracker: ConcurrencyTracker

    private(set) var fetchCount = 0

    init(outcome: ProviderResult<Int>, tracker: ConcurrencyTracker) {
        self.outcome = outcome
        self.tracker = tracker
    }

    var value: Int? {
        switch result {
        case .success(let value)?:
            value
        case .failure?, nil:
            nil
        }
    }

    func fetch(in database: DatabaseReader) async throws -> Int {
        fetchCount += 1
        tracker.enter()
        try await Task.sleep(for: .milliseconds(50))
        tracker.leave()
        return try outcome.get()
    }
}
