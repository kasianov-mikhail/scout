//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

@available(iOS 18, macOS 15, *)
struct CachedDatabase: Sendable {
    let base: any DatabaseReader
    let scope: String
    let cache: RecordCache
    let now: @Sendable () -> Date
    let types: Set<String>

    init(base: any DatabaseReader, scope: String, cache: RecordCache, now: @escaping @Sendable () -> Date = { Date() }, types: Set<String> = [EventEntry.recordType]) {
        self.base = base
        self.scope = scope
        self.cache = cache
        self.now = now
        self.types = types
    }
}
