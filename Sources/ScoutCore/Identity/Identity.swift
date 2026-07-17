//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct Identity: Sendable {
    let install: UUID
    let launch: UUID
    let device: UUID
    let session: Protected<UUID>
}

final class Protected<Value: Sendable>: @unchecked Sendable {
    private let queue = DispatchQueue(label: "scout.protected")

    nonisolated(unsafe) private(set) var raw: Value

    init(_ value: Value) {
        raw = value
    }

    var current: Value {
        get { queue.sync { raw } }
        set { queue.sync { raw = newValue } }
    }
}
