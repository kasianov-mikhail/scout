//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import UIKit

/// Adds a method `runner` to `CKDatabase`, which allows executing a closure with a configured
/// instance of the database. Also defines a `RunnerError` enum to handle timeout errors.
///
extension CKDatabase {

    /// Configures the `CKDatabase` with specified timeout intervals for requests and resources.
    /// If the background time remaining is less than 15 seconds, it throws a timeout error.
    ///
    func runner<R>(body: @Sendable (CKDatabase) async throws -> R) async throws -> R {
        guard await UIApplication.shared.backgroundTimeRemaining > 15 else {
            throw RunnerError()
        }

        let configuration = CKOperation.Configuration()
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 10

        return try await configuredWith(configuration: configuration, body: body)
    }

    struct RunnerError: LocalizedError {
        let errorDescription =
            "The operation was aborted because the remaining background time is insufficient."
    }
}
