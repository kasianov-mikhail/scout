//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct UserDefaultsUUIDTests {
    let defaults: UserDefaults
    let prefix: String

    init() {
        prefix = UUID().uuidString
        defaults = UserDefaults(suiteName: "UserDefaultsUUIDTests_\(prefix)")!
    }

    @Test("UUID round-trips through UserDefaults")
    func roundTrip() {
        let uuid = UUID()
        defaults.set(uuid, forKey: "\(prefix)_rt")
        let result = defaults.uuid(forKey: "\(prefix)_rt")
        #expect(result == uuid)
    }

    @Test("Returns nil for missing key")
    func missingKey() {
        let result = defaults.uuid(forKey: "\(prefix)_missing")
        #expect(result == nil)
    }

    @Test("Returns nil for non-UUID string")
    func invalidString() {
        defaults.set("not-a-uuid", forKey: "\(prefix)_bad")
        let result = defaults.uuid(forKey: "\(prefix)_bad")
        #expect(result == nil)
    }

    @Test("Overwrites previous value")
    func overwrite() {
        let first = UUID()
        let second = UUID()
        let key = "\(prefix)_overwrite"

        defaults.set(first, forKey: key)
        defaults.set(second, forKey: key)

        #expect(defaults.uuid(forKey: key) == second)
    }
}
