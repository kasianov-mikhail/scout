//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

actor LazyTable<Value: Sendable> {
    private var entries: [String: Task<Value, any Error>] = [:]

    func value(id: String, make: @escaping @Sendable () async throws -> Value) async throws -> Value {
        let entry = entries[id] ?? Task { try await make() }
        entries[id] = entry

        do {
            return try await entry.value
        } catch {
            // Only the failed task is evicted: a concurrent caller may have
            // already installed a fresh attempt under the same id.
            if entries[id] == entry {
                entries[id] = nil
            }
            throw error
        }
    }
}
