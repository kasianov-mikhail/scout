//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import UIKit

protocol Dispatcher {
    func perform(_ block: @escaping Block) async throws
}

extension Dispatcher {
    typealias Block = @Sendable () async throws -> Void
}

extension Dispatcher {
    func performEnsuringBackground(_ block: @escaping Block) async throws {
        try await perform { @MainActor in
            let task = UIApplication.shared.beginBackgroundTask()

            defer { UIApplication.shared.endBackgroundTask(task) }

            try await block()
        }
    }
}
