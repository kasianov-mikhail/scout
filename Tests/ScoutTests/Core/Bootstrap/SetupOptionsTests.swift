//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import Scout

@Suite("SetupOptions defaults")
struct SetupOptionsTests {
    @Test("Defaults match the legacy hard-coded values")
    func defaultsMatchLegacy() {
        let options = SetupOptions()

        #expect(options.crashReporting == .enabled)
        #expect(options.metrics == .enabled)
        #expect(options.logging == .enabled)

        #expect(options.sync.backgroundTimeThreshold == 15)
        #expect(options.sync.requestTimeout == 10)
        #expect(options.sync.maxConflictRetries == 3)

        #expect(options.retention.syncedRecordLifetime == 7 * 24 * 60 * 60)
        #expect(options.retention.maxSyncAttempts == 10)
    }
}
