//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

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

    @Test("Stability maps to the four health levels")
    func testLevels() {
        #expect(Stability(0.996).level == .healthy)
        #expect(Stability(0.992).level == .watch)
        #expect(Stability(0.985).level == .atRisk)
        #expect(Stability(0.970).level == .critical)
        #expect(Stability.Level.atRisk.title == "at risk")
        #expect(Stability.Level.atRisk.displayTitle == "At risk")
    }

    @Test("The scale marker spreads each health level across its own band")
    func testMarkerPosition() {
        #expect(abs(Stability(0.971).markerPosition - 0.00495) < 1e-9)
        #expect(abs(Stability(0.989).markerPosition - 0.45495) < 1e-9)
        #expect(abs(Stability(0.9921).markerPosition - 0.605) < 1e-9)
        #expect(abs(Stability(0.9982).markerPosition - 0.91) < 1e-9)
        #expect(Stability(0.95).markerPosition == 0)
        #expect(abs(Stability(1).markerPosition - 1) < 1e-9)
    }
}
