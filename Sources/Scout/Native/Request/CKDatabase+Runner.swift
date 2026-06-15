//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

extension CKDatabase {
    @discardableResult func runner<R>(body: @Sendable (CKDatabase) async throws -> R) async throws -> R {
        try await requireBackgroundTime()

        return try await requestLimiter.withSlot {
            try await configuredWith(configuration: .scout, body: body)
        }
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
