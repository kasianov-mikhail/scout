//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct SubscriptionLedger: @unchecked Sendable {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func signature(containerID: String) -> String? {
        defaults.string(forKey: Self.key(containerID: containerID))
    }

    func record(containerID: String, signature: String) {
        defaults.set(signature, forKey: Self.key(containerID: containerID))
    }

    func clear(containerID: String) {
        defaults.removeObject(forKey: Self.key(containerID: containerID))
    }

    static func key(containerID: String) -> String {
        "scout.subscriptions.\(containerID).signature"
    }
}
