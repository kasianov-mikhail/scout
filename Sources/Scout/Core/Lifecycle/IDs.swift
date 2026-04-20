//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

enum IDs {
    nonisolated(unsafe) static var session: UUID?

    static let launch = UUID()

    static let install: UUID = {
        let key = "scout_install_id"

        if let id = UserDefaults.standard.uuid(forKey: key) {
            return id
        }

        let id = UUID()
        UserDefaults.standard.set(id, forKey: key)
        return id
    }()

    static let device: UUID = {
        let key = "scout_device_id"

        if let id = KeychainID.load(key: key) {
            return id
        }

        let id = UUID()
        KeychainID.save(key: key, value: id)
        return id
    }()
}
