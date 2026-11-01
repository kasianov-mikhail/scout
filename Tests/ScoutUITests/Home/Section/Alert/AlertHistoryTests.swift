//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import ScoutUI

struct AlertHistoryTests {
    @Test("The sample history fills 24 buckets")
    func buckets() {
        let history = AlertHistory.sample

        #expect(history.buckets.count == 24)
        #expect(history.buckets.count(where: { $0 == .clear }) == 12)
        #expect(history.buckets.count(where: { $0 == .muted }) == 5)
        #expect(history.buckets.count(where: { $0 == .firing }) == 7)
    }

    @Test("The summary reads the rule and the rule counts")
    func summary() {
        let history = AlertHistory.sample

        #expect(history.summary == "Crash-free sessions · 4 armed · 1 muted")
        #expect(history.rulesLabel == "6 rules")
        #expect(history.firing == 1)
    }

    @Test("One rule reads in the singular")
    func singular() {
        let history = AlertHistory(
            buckets: [],
            rule: "Crash-free sessions",
            firing: 0,
            armed: 1,
            muted: 0,
            total: 1
        )

        #expect(history.rulesLabel == "1 rule")
    }
}
