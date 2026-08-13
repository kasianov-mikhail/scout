//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

// The keychain owns the device ID because it survives a reinstall, but it cannot
// be read before the first unlock after a reboot — where iOS still prewarms and
// background-launches apps. A read that fails there is indistinguishable from a
// missing item, and minting a replacement would attribute the whole launch to a
// device that never appears again. The mirror answers instead, and either side
// heals the other once it can be written.
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
