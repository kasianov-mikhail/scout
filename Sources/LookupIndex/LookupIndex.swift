//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout

/// The record-cache module for Scout.
///
/// The cache is backed by SwiftData and its compound `#Index`, which is
/// available only on iOS 18 and macOS 15. It lives in a separate module so the
/// core `Scout` framework — and anything that only links it, including its test
/// bundles — does not link SwiftData and keeps loading on earlier systems.
///
public enum LookupIndex {
    /// Routes Scout's backends through the SwiftData-backed record cache.
    ///
    /// Call this once during app startup. Without it, `Scout` resolves every
    /// backend to its uncached database. On systems earlier than iOS 18 /
    /// macOS 15 — or when the cache store cannot be opened — the call is a
    /// no-op and backends stay uncached.
    ///
    @MainActor public static func enable() {
        guard #available(iOS 18, macOS 15, *) else {
            return
        }
        do {
            CachedDatabase.cache = try RecordCache()
        } catch {
            print("Failed to open the record cache store, so backends stay uncached until the next launch: \(error)")
        }
    }
}
