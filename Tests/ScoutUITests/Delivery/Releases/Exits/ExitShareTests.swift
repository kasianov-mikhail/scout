//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import Testing

@testable import ScoutUI

@Suite("Exit share")
struct ExitShareTests {
    @Test("The share is measured per thousand exits")
    func perMille() {
        let share = ExitShare(reason: .watchdog, count: 6, total: 1000)

        #expect(share.perMille == 6)
        #expect(share.formatted == "6.0 ‰")
        #expect(share.id == .watchdog)
    }

    @Test("A fractional share keeps one decimal")
    func fraction() {
        #expect(ExitShare(reason: .badAccess, count: 1, total: 3).formatted == "333.3 ‰")
    }

    @Test("A zero total gives a zero share")
    func zeroTotal() {
        let share = ExitShare(reason: .normal, count: 5, total: 0)

        #expect(share.perMille == 0)
        #expect(share.formatted == "0.0 ‰")
    }
}
