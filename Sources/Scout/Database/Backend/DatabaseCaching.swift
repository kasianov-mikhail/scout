//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package protocol CacheClearing: Actor {
    var size: Int64 { get }
    func removeAll()
}

package protocol DatabaseCaching: CacheClearing {
    nonisolated func cached(_ database: any Database, scope: String) -> any Database
}

extension Backend {
    @MainActor package static var cache: (any DatabaseCaching)?

    @MainActor package var cachedDatabase: any Database {
        Self.cache?.cached(database, scope: id) ?? database
    }
}
