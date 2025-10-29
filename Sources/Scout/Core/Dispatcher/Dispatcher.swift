//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import UIKit

protocol Dispatcher {
    func perform(_ block: @escaping DispatchBlock) async throws
}

typealias DispatchBlock = @Sendable () async throws -> Void

extension Dispatcher {
    func performEnsuringBackground(_ block: @escaping DispatchBlock) async throws {
        try await perform {
            let task = await UIApplication.shared.beginBackgroundTask()

            defer {
                Task {
                    await UIApplication.shared.endBackgroundTask(task)
                }
            }

            try await block()
        }
    }
}
