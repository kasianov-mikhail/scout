//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CryptoKit
import Foundation

extension UUID {
    init(digesting parts: [String]) {
        let digest = Array(SHA256.hash(data: Data(parts.joined(separator: "\n").utf8)))
        self = digest.withUnsafeBufferPointer { NSUUID(uuidBytes: $0.baseAddress) as UUID }
    }
}
