//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

/// Runs work items one at a time, coalescing submissions that arrive mid-run.
///
/// Callers submit work that processes everything accumulated so far (a sync run),
/// so keeping more than one pending item is pointless: while a run is in flight,
/// each new submission replaces the pending one, and at most one follow-up run
/// executes after the current run finishes.
///
actor QueueDispatcher: Dispatcher {
    private var pending: Work?
    private var isRunning = false

    func perform(_ work: @escaping Work) async throws {
        pending = work

        guard !isRunning else { return }

        isRunning = true

        defer { isRunning = false }

        while let next = pending {
            pending = nil

            do {
                try await next()
            } catch {
                pending = nil
                throw error
            }
        }
    }
}
