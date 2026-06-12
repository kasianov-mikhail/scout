//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

#if os(iOS)
    import UIKit
#endif

extension CKDatabase {
    @discardableResult func runner<R>(body: @Sendable (CKDatabase) async throws -> R) async throws -> R {
        #if os(iOS)
            guard await UIApplication.shared.backgroundTimeRemaining > 15 else {
                throw RunnerError()
            }
        #endif

        return try await requestLimiter.withSlot {
            try await configuredWith(configuration: .scout, body: body)
        }
    }

    struct RunnerError: LocalizedError {
        let errorDescription: String? = "The operation was aborted because the remaining background time is insufficient."
        let failureReason: String? = "Not enough background time remaining."
        let helpAnchor: String? = "https://developer.apple.com/documentation/uikit/uiapplication/backgroundtimeremaining"
        let recoverySuggestion: String? = "Try again later."
    }
}

extension CKOperation.Configuration {
    /// The configuration for every Scout CloudKit request, measurement requests included.
    static var scout: CKOperation.Configuration {
        let configuration = CKOperation.Configuration()
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 10
        return configuration
    }
}
