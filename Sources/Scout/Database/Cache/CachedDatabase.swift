//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package struct CachedDatabase: Sendable {
    @MainActor package static var cache: (any RecordCaching)?

    let base: any Database
    let scope: String
    let cache: any RecordCaching
    let now: @Sendable () -> Date
    let types: Set<String>

    package init(base: any Database, scope: String, cache: any RecordCaching, now: @escaping @Sendable () -> Date = { Date() }, types: Set<String> = [EventEntry.recordType]) {
        self.base = base
        self.scope = scope
        self.cache = cache
        self.now = now
        self.types = types
    }
}
