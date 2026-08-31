//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout

@MainActor
final class CacheStatus: ObservableObject {
    @Published private(set) var bytes: Int64

    private let storage: CacheStorage

    init(storage: CacheStorage) {
        self.storage = storage
        bytes = storage.bytes()
    }

    var isEmpty: Bool {
        bytes == 0
    }

    var sizeLabel: String {
        isEmpty ? "Empty" : bytes.formatted(.byteCount(style: .file))
    }

    func clear() {
        storage.removeAll()
        bytes = storage.bytes()
    }
}
