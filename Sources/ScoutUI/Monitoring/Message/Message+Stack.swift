//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension [Message] {
    private static let maxVisible = 5

    mutating func push(_ message: Message) {
        append(message)
        self = Array(suffix(Self.maxVisible))
    }

    mutating func dismiss(_ message: Message) {
        removeAll { $0.id == message.id }
    }
}
