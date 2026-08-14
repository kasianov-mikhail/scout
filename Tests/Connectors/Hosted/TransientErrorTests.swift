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
    @Test("Connectivity failures are transient")
    func urlErrorsAreTransient() {
        #expect(URLError(.notConnectedToInternet).isTransient)
        #expect(URLError(.timedOut).isTransient)
        #expect(URLError(.networkConnectionLost).isTransient)
    }

    @Test("Server-side outages and throttling are transient")
    func serverOutagesAreTransient() {
        #expect(HTTPDatabaseError(status: 500, reason: nil).isTransient)
        #expect(HTTPDatabaseError(status: 503, reason: nil).isTransient)
        #expect(HTTPDatabaseError(status: 429, reason: nil).isTransient)
    }

    @Test("Rejections count against the attempt budget")
    func rejectionsAreNotTransient() {
        #expect(!HTTPDatabaseError(status: 400, reason: "bad record").isTransient)
        #expect(!HTTPDatabaseError(status: 422, reason: nil).isTransient)
        #expect(!((NSError(domain: "Test", code: 1) as any Error) is any TransientFailure))
    }
}
