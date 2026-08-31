//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout

actor SampleCacheStorage: CacheStorage {
    private var size: Int64

    init(bytes: Int64) {
        self.size = bytes
    }

    func bytes() -> Int64 {
        size
    }

    func removeAll() {
        size = 0
    }
}

extension CacheStorage where Self == SampleCacheStorage {
    static var sample: SampleCacheStorage {
        .sample(bytes: 12_582_912)
    }

    static func sample(bytes: Int64) -> SampleCacheStorage {
        SampleCacheStorage(bytes: bytes)
    }
}
