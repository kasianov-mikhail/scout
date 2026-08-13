//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import Testing

@testable import HostedConnector

@Suite("Hosted transient error classification")
struct TransientErrorTests {
    let backend = Backend.server(url: URL(string: "https://example.com")!, apiKey: nil)

    @Test("Connectivity failures are transient")
    func urlErrorsAreTransient() {
        #expect(backend.isTransientError(URLError(.notConnectedToInternet)))
        #expect(backend.isTransientError(URLError(.timedOut)))
        #expect(backend.isTransientError(URLError(.networkConnectionLost)))
    }

    @Test("Server-side outages and throttling are transient")
    func serverOutagesAreTransient() {
        #expect(backend.isTransientError(HTTPDatabaseError(status: 500, reason: nil)))
        #expect(backend.isTransientError(HTTPDatabaseError(status: 503, reason: nil)))
        #expect(backend.isTransientError(HTTPDatabaseError(status: 429, reason: nil)))
    }

    @Test("Rejections count against the attempt budget")
    func rejectionsAreNotTransient() {
        #expect(!backend.isTransientError(HTTPDatabaseError(status: 400, reason: "bad record")))
        #expect(!backend.isTransientError(HTTPDatabaseError(status: 422, reason: nil)))
        #expect(!backend.isTransientError(NSError(domain: "Test", code: 1)))
    }
}
