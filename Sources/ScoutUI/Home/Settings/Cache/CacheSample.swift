//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Scout

actor CacheSample: CacheClearing {
    private(set) var size: Int64

    init(size: Int64 = 12_582_912) {
        self.size = size
    }

    func removeAll() {
        size = 0
    }
}
