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

    // A store of its own per backend brings a schema cache of its own with it,
    // so a caller building backends in a view body republishes the catalog on
    // every rebuild.
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
