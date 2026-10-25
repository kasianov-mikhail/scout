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
struct ProviderTests {
    @Test("A failed refresh keeps the loaded result and returns the error")
    func refreshFailureKeepsResult() async throws {
        let provider = ProviderStub(outcome: .success(1))
        await provider.fetchLatest(in: DatabaseStub())

        provider.outcome = .failure(StubFailure())
        let error = await provider.refresh(in: DatabaseStub())

        #expect(error != nil)
        #expect(try provider.result?.get() == 1)
    }

    @Test("A failed refresh before the first load shows the error in place of the result")
    func refreshFailureWithoutResult() async {
        let provider = ProviderStub(outcome: .failure(StubFailure()))

        let error = await provider.refresh(in: DatabaseStub())

        #expect(error == nil)
        #expect(provider.error != nil)
    }

    @Test("A successful refresh replaces the loaded result")
    func refreshReplacesResult() async throws {
        let provider = ProviderStub(outcome: .success(1))
        await provider.fetchLatest(in: DatabaseStub())

        provider.outcome = .success(2)
        let error = await provider.refresh(in: DatabaseStub())

        #expect(error == nil)
        #expect(try provider.result?.get() == 2)
    }

    @Test("A failed refresh of several providers keeps every loaded result")
    func refreshAllKeepsResults() async throws {
        let failing = ProviderStub(outcome: .success(1))
        let passing = ProviderStub(outcome: .success(2))
        let providers: [any Refreshable] = [failing, passing]
        await providers.fetchLatest(in: DatabaseStub())

        failing.outcome = .failure(StubFailure())
        passing.outcome = .success(3)
        let error = await providers.refresh(in: DatabaseStub())

        #expect(error != nil)
        #expect(try failing.result?.get() == 1)
        #expect(try passing.result?.get() == 3)
    }
}

@MainActor
private final class ProviderStub: ObservableObject, Provider {
    @Published var result: ProviderResult<Int>?

    var outcome: ProviderResult<Int>

    init(outcome: ProviderResult<Int>) {
        self.outcome = outcome
    }

    func fetch(in database: DatabaseReader) async throws -> Int {
        try outcome.get()
    }
}

private struct StubFailure: Error {}
