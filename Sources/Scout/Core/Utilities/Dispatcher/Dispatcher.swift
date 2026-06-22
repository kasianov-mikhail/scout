//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

#if os(iOS)
    import UIKit
#else
    import Foundation
#endif

protocol Dispatcher: Sendable {
    func perform(_ work: @escaping Work) async throws
}

extension Dispatcher {
    typealias Work = @Sendable () async throws -> Void
}

extension Dispatcher {
    func performEnsuringBackground(_ work: @escaping Work) async throws {
        #if os(iOS)
            try await perform { @MainActor in
                let work = Task(operation: work)
                let task = UIApplication.shared.beginBackgroundTask(withName: "scout.sync", expirationHandler: work.cancel)

                defer { UIApplication.shared.endBackgroundTask(task) }

                try await work.value
            }
        #else
            try await perform(work)
        #endif
    }
}
