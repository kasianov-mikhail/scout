//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

typealias DispatchBlock = @Sendable () async throws -> Void

protocol Dispatcher {
    func execute(_ block: @escaping DispatchBlock) async rethrows
}

actor SkipDispatcher: Dispatcher {
    private var isRunning = false

    func execute(_ block: @escaping DispatchBlock) async rethrows {
        guard !isRunning else {
            return
        }
        isRunning = true
        defer {
            isRunning = false
        }
        try await block()
    }
}
