//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import UIKit

protocol Dispatcher: Sendable {
    func perform(_ work: @escaping Work) async throws
}

extension Dispatcher {
    typealias Work = @Sendable () async throws -> Void
}

extension Dispatcher {
    /// Cancels `work` on expiration rather than letting iOS silently revoke background time.
    func performEnsuringBackground(_ work: @escaping Work) async throws {
        try await perform { @MainActor in
            let work = Task(operation: work)
            let task = UIApplication.shared.beginBackgroundTask(withName: "scout.sync", expirationHandler: work.cancel)

            defer { UIApplication.shared.endBackgroundTask(task) }

            try await work.value
        }
    }
}
