//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

private let grantLifetime: TimeInterval = 300
private let denialLifetime: TimeInterval = 30

actor AccessCache {
    private let now: @Sendable () -> Date
    private var verdict: Verdict?
    private var generation = 0

    init(now: @escaping @Sendable () -> Date) {
        self.now = now
    }

    func check(ping: @Sendable () async throws -> Void) async throws {
        if let verdict, verdict.expiry > now() {
            return try verdict.result.get()
        }

        let start = generation
        let result: Result<Void, any Error>
        do {
            try await ping()
            result = .success(())
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            result = .failure(error)
        }

        if generation == start {
            verdict = Verdict(result: result, now: now())
        }
        try result.get()
    }

    func invalidate() {
        verdict = nil
        generation += 1
    }
}

private struct Verdict {
    let result: Result<Void, any Error>
    let expiry: Date
}

extension Verdict {
    init(result: Result<Void, any Error>, now: Date) {
        self.result = result
        switch result {
        case .success:
            self.expiry = now + grantLifetime
        case .failure:
            self.expiry = now + denialLifetime
        }
    }
}
