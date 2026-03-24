//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension UserDefaults {
    func set(_ value: UUID, forKey key: String) {
        set(value.uuidString, forKey: key)
    }

    func uuid(forKey key: String) -> UUID? {
        guard let string = string(forKey: key) else { return nil }
        return UUID(uuidString: string)
    }
}
