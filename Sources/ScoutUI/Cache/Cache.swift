//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout

/// The record-cache module for Scout.
///
/// The cache is backed by SwiftData, which is available only on iOS 17 and
/// macOS 14. It lives in a separate module so the core `Scout` framework — and
/// anything that only links it, including its test bundles — does not link
/// SwiftData and keeps loading on earlier systems.
///
public enum Cache {
    /// Routes Scout's backends through the SwiftData-backed record cache.
    ///
    /// Call this once during app startup. Without it, `Scout` resolves every
    /// backend to its uncached database. On systems earlier than iOS 17 /
    /// macOS 14 the call is a no-op and backends stay uncached.
    ///
    @MainActor public static func enable() {
        DatabaseCaching.provider = { backend in
            guard #available(iOS 17, macOS 14, *) else { return nil }
            return DatabaseCacheRegistry.database(for: backend)
        }
    }
}
