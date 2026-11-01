//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import ScoutUI

struct ActiveUsersTests {
    @Test("The sample carries the three metrics in order")
    func metrics() {
        let users = ActiveUsers.sample

        #expect(users.metrics.map(\.kind) == [.dau, .sessions, .devices])
        #expect(users.metrics.map(\.kind.title) == ["DAU", "SESSIONS", "DEVICES"])
        #expect(users.metrics.allSatisfy { $0.series.count == 30 })
    }

    @Test("Values and deltas read as the mock")
    func labels() throws {
        let users = ActiveUsers.sample
        let dau = try #require(users.metric(.dau))
        let sessions = try #require(users.metric(.sessions))
        let devices = try #require(users.metric(.devices))

        #expect(dau.valueLabel == "1,212")
        #expect(dau.deltaLabel == "+4.1%")
        #expect(sessions.valueLabel == "8,412")
        #expect(sessions.deltaLabel == "+12.3%")
        #expect(devices.valueLabel == "38")
        #expect(devices.deltaLabel == "+12%")
        #expect(users.stickinessLabel == "8.5%")
        #expect(users.sessionsPerUserLabel == "6.9")
    }
}
