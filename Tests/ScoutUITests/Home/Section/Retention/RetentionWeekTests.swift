//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import ScoutUI

struct RetentionWeekTests {
    @Test("The sample carries four weekly cohorts")
    func sample() {
        let weeks = [RetentionWeek].sample

        #expect(weeks.count == 4)
        #expect(weeks.map(\.installs) == [1104, 960, 1142, 787])
        #expect(weeks.map(\.kept) == [nil, 192, 217, 142])
    }

    @Test("Kept over installs reads the rate")
    func rate() throws {
        let weeks = [RetentionWeek].sample
        let week = try #require(weeks.first { $0.kept == 192 })

        #expect(week.rate == 0.2)
        #expect(Int(((week.rate ?? 0) * 100).rounded()) == 20)
    }

    @Test("A cohort without day 7 reads as pending")
    func pending() throws {
        let pending = try #require([RetentionWeek].sample.first { $0.kept == nil })

        #expect(pending.rate == nil)
        #expect(pending.pendingDays == 2)
        #expect(pending.pendingLabel == "in 2 d")
    }
}
