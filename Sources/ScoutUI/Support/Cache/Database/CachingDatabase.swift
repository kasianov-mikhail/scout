//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct CachingDatabase: Sendable {
    let base: any Database
    let scope: String
    let cache: RecordCache
    let now: @Sendable () -> Date
    let types: Set<String>
}
