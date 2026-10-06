//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import Testing

@testable import NativeConnector

@Suite("Native transient error classification")
struct TransientErrorTests {
    @Test("Connectivity and service failures are transient")
    func connectivityIsTransient() {
        #expect(CKError(.networkUnavailable).isTransient)
        #expect(CKError(.networkFailure).isTransient)
        #expect(CKError(.serviceUnavailable).isTransient)
        #expect(CKError(.requestRateLimited).isTransient)
        #expect(CKError(.zoneBusy).isTransient)
        #expect(CKError(.accountTemporarilyUnavailable).isTransient)
        #expect(CKError(.operationCancelled).isTransient)
    }

    @Test("Rejections are not transient")
    func rejectionsAreNotTransient() {
        #expect(!CKError(.invalidArguments).isTransient)
        #expect(!CKError(.serverRejectedRequest).isTransient)
        #expect(!CKError(.permissionFailure).isTransient)
    }

    @Test("A retry-after hint marks any error transient")
    func retryAfterHintIsTransient() {
        let error = CKError(.serverResponseLost, userInfo: [CKErrorRetryAfterKey: 30.0])
        #expect(error.isTransient)
    }
}
