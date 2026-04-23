//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

enum IDs {
    private static let sessionQueue = DispatchQueue(label: "scout.ids.session")

    nonisolated(unsafe) private static var sessionStorage = UUID()

    /// Rotates on every `SessionObject.trigger`. `TrackedObject.awakeFromInsert`
    /// reads it from arbitrary Core Data background contexts, so access is
    /// serialised through a dispatch queue to avoid torn reads when rotation
    /// races with concurrent inserts.
    ///
    static var session: UUID {
        get { sessionQueue.sync { sessionStorage } }
        set { sessionQueue.sync { sessionStorage = newValue } }
    }

    static let launch = UUID()

    static let install = UserDefaults.standard.ensure("scout_install_id")

    static let device = KeychainStorage.standard.ensure("scout_device_id")
}
