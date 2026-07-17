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

// The record cache lives in the ScoutCache module (it links SwiftData, iOS 17+),
// which Scout must not depend on. ScoutCache.enable() installs the provider here;
// until it does, backends resolve to their uncached database.
@MainActor
package enum DatabaseCaching {
    package static var provider: (@MainActor @Sendable (Backend) -> (any Database)?)?
}

// Record types whose lookups the cache is allowed to persist. Sourced here so the
// ScoutCache module need not reach the record entry types directly.
package enum CachedLookupTypes {
    package static let all: Set<String> = [EventEntry.recordType]
}
