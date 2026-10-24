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

    @Test("A wrapped URL failure reads as transient through any Error and keeps its classification")
    func transportErrorForwardsURLError() {
        let offline: any Error = HTTPTransportError(error: URLError(.notConnectedToInternet))
        let blocked: any Error = HTTPTransportError(error: URLError(.appTransportSecurityRequiresSecureConnection))

        #expect((offline as? any TransientFailure)?.isTransient == true)
        #expect((offline as? any TransientFailure)?.misconfiguration == nil)
        #expect((blocked as? any TransientFailure)?.misconfiguration != nil)
        #expect(offline.localizedDescription == URLError(.notConnectedToInternet).localizedDescription)
    }

    @Test("Server-side outages and throttling are transient")
    func serverOutagesAreTransient() {
        #expect(HTTPDatabaseError(status: 500, reason: nil).isTransient)
        #expect(HTTPDatabaseError(status: 503, reason: nil).isTransient)
        #expect(HTTPDatabaseError(status: 429, reason: nil).isTransient)
        #expect(HTTPDatabaseError(status: 408, reason: nil).isTransient)
    }

    @Test("Auth and routing failures keep records pending and name the misconfiguration", arguments: [401, 403, 404])
    func authAndRoutingFailuresAreMisconfigurations(status: Int) {
        let error = HTTPDatabaseError(status: status, reason: nil)

        #expect(error.isTransient)
        #expect(error.misconfiguration != nil)
    }

    @Test(
        "Blocked, malformed and untrusted URLs keep records pending and name the misconfiguration",
        arguments: [
            URLError.Code.appTransportSecurityRequiresSecureConnection,
            .badURL,
            .unsupportedURL,
            .secureConnectionFailed,
            .serverCertificateHasBadDate,
            .serverCertificateUntrusted,
            .serverCertificateHasUnknownRoot,
            .serverCertificateNotYetValid,
            .clientCertificateRejected,
            .clientCertificateRequired,
        ]
    )
    func urlMisconfigurations(code: URLError.Code) {
        let error = URLError(code)

        #expect(error.isTransient)
        #expect(error.misconfiguration != nil)
    }

    @Test("Connectivity, outages and throttling are not misconfigurations")
    func transientFailuresAreNotMisconfigurations() {
        #expect(URLError(.notConnectedToInternet).misconfiguration == nil)
        #expect(URLError(.timedOut).misconfiguration == nil)
        #expect(URLError(.networkConnectionLost).misconfiguration == nil)
        #expect(HTTPDatabaseError(status: 408, reason: nil).misconfiguration == nil)
        #expect(HTTPDatabaseError(status: 429, reason: nil).misconfiguration == nil)
        #expect(HTTPDatabaseError(status: 503, reason: nil).misconfiguration == nil)
        #expect(InsufficientBackgroundTimeError().misconfiguration == nil)
    }

    @Test("Running out of background time is transient")
    func backgroundTimeExhaustionIsTransient() {
        #expect(InsufficientBackgroundTimeError().isTransient)
    }

    @Test("Rejections count against the attempt budget")
    func rejectionsAreNotTransient() {
        #expect(!HTTPDatabaseError(status: 400, reason: "bad record").isTransient)
        #expect(!HTTPDatabaseError(status: 413, reason: nil).isTransient)
        #expect(!HTTPDatabaseError(status: 422, reason: nil).isTransient)
        #expect(!((NSError(domain: "Test", code: 1) as any Error) is any TransientFailure))
    }
}
