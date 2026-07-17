//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

protocol Registry {
    func resolve(_ key: String) -> UUID?
    func register(_ value: UUID, for key: String)
}

extension Registry {
    func ensure(_ key: String) -> UUID {
        if let id = resolve(key) {
            return id
        }

        let id = UUID()
        register(id, for: key)
        return id
    }
}

extension UserDefaults: Registry {
    func register(_ value: UUID, for key: String) {
        set(value.uuidString, forKey: key)
    }

    func resolve(_ key: String) -> UUID? {
        guard let string = string(forKey: key) else { return nil }
        return UUID(uuidString: string)
    }
}
