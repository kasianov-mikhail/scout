//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// A key-value store for persistent identifiers.
protocol Registry {
    /// Returns the identifier for the given key, or `nil` if none exists.
    func resolve(_ key: String) -> UUID?

    /// Stores the identifier for the given key.
    func register(_ value: UUID, for key: String)
}

extension Registry {
    /// Returns the existing identifier for the key, or creates and stores a new one.
    func ensure(_ key: String) -> UUID {
        if let id = resolve(key) {
            return id
        }

        let id = UUID()
        register(id, for: key)
        return id
    }
}
