//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// Serializes persistent-store connections opened by concurrently running tests.
///
/// Core Data — the engine SwiftData is built on — is not safe to connect from
/// several threads at once: two `addPersistentStore`/`ModelContainer`
/// connections building their schema in parallel race inside Core Data's shared
/// trigger-SQL machinery, corrupt an internal dictionary, and crash the whole
/// xctest process with `EXC_BAD_ACCESS`. Swift Testing runs suites in parallel,
/// so tests that each open their own store funnel every connection through this
/// one process-wide lock. Production opens each store exactly once, so it needs
/// no such guard.
///
public enum SerializedStore {
    private static let lock = NSLock()

    /// Runs `body` while holding the process-wide store-connection lock.
    ///
    public static func connect<T>(_ body: () throws -> T) rethrows -> T {
        lock.lock()
        defer { lock.unlock() }
        return try body()
    }
}
