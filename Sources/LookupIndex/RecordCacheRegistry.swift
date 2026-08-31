//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout

@available(iOS 17, macOS 14, *)
@MainActor
enum RecordCacheRegistry {
    private enum CacheState {
        case unresolved
        case unavailable
        case ready(any RecordCaching)
    }

    private static var state: CacheState = .unresolved

    static func database(for backend: Backend) -> any Database {
        guard let cache = sharedCache() else {
            return backend.database
        }
        return CachedDatabase(base: backend.database, scope: backend.id, cache: cache)
    }

    private static func sharedCache() -> (any RecordCaching)? {
        switch state {
        case .unresolved:
            let created = RecordCacheStore.cache()
            state = created.map(CacheState.ready) ?? .unavailable
            return created
        case .unavailable:
            return nil
        case .ready(let cache):
            return cache
        }
    }
}
