//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Backend {
    @MainActor package var cachedDatabase: any Database {
        DatabaseCaching.provider?(self) ?? database
    }
}

@MainActor package enum DatabaseCaching {
    package static var provider: (@MainActor @Sendable (Backend) -> (any Database)?)?
    package static var storage: CacheStorage?
}

package struct CacheStorage {
    package let size: @MainActor () -> Int64
    package let clear: @MainActor () -> Void

    package init(size: @escaping @MainActor () -> Int64, clear: @escaping @MainActor () -> Void) {
        self.size = size
        self.clear = clear
    }
}

package enum CachedLookupTypes {
    package static let all: Set<String> = [EventEntry.recordType]
}
