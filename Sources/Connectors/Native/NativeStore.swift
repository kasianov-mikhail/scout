//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

enum NativeStore {
    private static let lock = NSLock()
    nonisolated(unsafe) private static var stores: [String: NativeDatabase] = [:]

    /// The store this container already has, or the one `make` builds for it.
    ///
    /// A backend is a value a caller may build wherever it is needed, a view
    /// body included, and a store of its own per call brings a schema cache of
    /// its own with it: every rebuild reads the catalog back from the server
    /// and publishes what it does not find. One store per container is what
    /// keeps that a launch's worth of requests rather than a body's.
    ///
    static func shared(id: String, make: () -> NativeDatabase) -> NativeDatabase {
        lock.lock()
        defer { lock.unlock() }

        if let stored = stores[id] {
            return stored
        }
        let store = make()
        stores[id] = store
        return store
    }
}
