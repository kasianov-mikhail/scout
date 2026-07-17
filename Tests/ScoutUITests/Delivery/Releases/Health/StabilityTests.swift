//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import ScoutCore
@testable import ScoutUI

struct StabilityTests {
    @Test("Crash-free fraction is derived from affected sessions")
    func testFraction() {
        #expect(Stability(of: 1, in: 4).value == 0.75)
        #expect(Stability(of: 0, in: 4).value == 1)
    }

    @Test("No sessions and no crashes reads as fully stable")
    func testEmptyIsStable() {
        #expect(Stability(of: 0, in: 0).value == 1)
    }

    @Test("Crashes without recorded sessions read as zero crash-free, not perfect")
    func testCrashesWithoutSessions() {
        #expect(Stability(of: 3, in: 0).value == 0)
    }
}
