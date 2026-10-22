//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct MirroredRegistry: Registry {
    let store: any Registry
    let mirror: any Registry

    func resolve(_ key: String) -> UUID? {
        let stored = store.resolve(key)
        let mirrored = mirror.resolve(key)

        guard let id = stored ?? mirrored else {
            return nil
        }

        if stored != id {
            store.register(id, for: key)
        }
        if mirrored != id {
            mirror.register(id, for: key)
        }

        return id
    }

    func register(_ value: UUID, for key: String) {
        store.register(value, for: key)
        mirror.register(value, for: key)
    }
}
