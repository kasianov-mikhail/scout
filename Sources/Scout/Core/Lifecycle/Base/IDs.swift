//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

enum IDs {
    nonisolated(unsafe) static var session = UUID()

    static let launch = UUID()

    static let install = UserDefaults.standard.ensure("scout_install_id")

    static let device = KeychainStorage.standard.ensure("scout_device_id")
}
