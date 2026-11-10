//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import SwiftUI
import Testing

@testable import ScoutUI

@Suite("BackendRetention")
struct BackendRetentionTests {
    @Test("A choice is saved per backend")
    func savesPerBackend() throws {
        let name = "scout-retention-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: name))
        defer { defaults.removePersistentDomain(forName: name) }

        AppStorage(wrappedValue: BackendRetention.year, BackendRetention.key(id: "a"), store: defaults).wrappedValue = .days30

        let saved = AppStorage(wrappedValue: BackendRetention.year, BackendRetention.key(id: "a"), store: defaults)
        let other = AppStorage(wrappedValue: BackendRetention.year, BackendRetention.key(id: "b"), store: defaults)

        #expect(saved.wrappedValue == .days30)
        #expect(other.wrappedValue == .year)
    }

    @Test("An unset backend reads the default")
    func readsDefault() throws {
        let name = "scout-retention-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: name))
        defer { defaults.removePersistentDomain(forName: name) }

        let retention = AppStorage(wrappedValue: BackendRetention.year, BackendRetention.key(id: "a"), store: defaults)

        #expect(retention.wrappedValue == .year)
    }

    @Test("Each backend gets its own key")
    func keysAreDistinct() {
        #expect(BackendRetention.key(id: "a") != BackendRetention.key(id: "b"))
    }
}
