//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

@MainActor package struct CacheStorage {
    package let bytes: () -> Int64
    package let removeAll: () -> Void

    package init(bytes: @escaping () -> Int64, removeAll: @escaping () -> Void) {
        self.bytes = bytes
        self.removeAll = removeAll
    }
}

extension CacheStorage {
    package static var sample: CacheStorage {
        sample(bytes: 12_582_912)
    }

    package static func sample(bytes: Int64) -> CacheStorage {
        var bytes = bytes
        return CacheStorage(
            bytes: { bytes },
            removeAll: { bytes = 0 }
        )
    }
}
