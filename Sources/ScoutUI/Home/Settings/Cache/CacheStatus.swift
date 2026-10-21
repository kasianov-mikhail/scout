//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

@MainActor
final class CacheStatus: ObservableObject {
    @Published private(set) var bytes: Int64?

    private let cache: any CacheClearing

    init(cache: any CacheClearing) {
        self.cache = cache
    }

    var isEmpty: Bool {
        bytes == 0
    }

    var sizeLabel: String {
        switch bytes {
        case nil:
            ""
        case 0:
            "Empty"
        case let bytes?:
            bytes.formatted(.byteCount(style: .file).locale(Locale(identifier: "en_US")))
        }
    }

    func refresh() async {
        bytes = await cache.size
    }

    func clear() async {
        await cache.removeAll()
        await refresh()
    }
}
