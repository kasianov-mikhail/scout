//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

actor LazyTable<Value: Sendable> {
    private var entries: [String: Task<Value, Never>] = [:]

    func value(id: String, make: @escaping @Sendable () async -> Value) async -> Value {
        if let entry = entries[id] {
            return await entry.value
        }

        let entry = Task { await make() }
        entries[id] = entry

        return await entry.value
    }
}
