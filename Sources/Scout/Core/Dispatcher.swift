//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

/// An actor responsible for managing the execution of asynchronous tasks, ensuring that only one task runs at a time.
///
/// The `Dispatcher` actor provides a mechanism to execute asynchronous tasks sequentially, preventing concurrent execution
/// of multiple tasks. This is useful in scenarios where tasks need to be executed one at a time to avoid race conditions
/// or other concurrency issues.
///
actor Dispatcher {

    /// A flag indicating whether a task is currently running.
    private var isRunning = false

    /// Executes the given asynchronous block if no other task is currently running.
    ///
    /// This method ensures that only one task is executed at a time. If a task is already running, the method returns
    /// immediately without executing the block. Otherwise, it sets the `isRunning` flag to `true`, executes the block,
    /// and then resets the flag to `false` once the block completes.
    ///
    /// - Parameter block: The asynchronous block to be executed.
    /// - Throws: Rethrows any error thrown by the block.
    ///
    func execute(_ block: @escaping () async throws -> Void) async rethrows {
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
