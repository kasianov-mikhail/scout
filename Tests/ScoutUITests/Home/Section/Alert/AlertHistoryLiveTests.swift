//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import ScoutUI

struct AlertHistoryLiveTests {
    @Test("Statuses map to counts and rule name")
    func counts() {
        let history = AlertHistory(statuses: [.firingSample, .armedSample])

        #expect(history.total == 2)
        #expect(history.firing == 1)
        #expect(history.armed == 1)
        #expect(history.muted == 0)
        #expect(history.rule == "Crash-free sessions")
        #expect(history.buckets.count == 24)
    }

    @Test("Breached recent buckets read as firing")
    func buckets() {
        let history = AlertHistory(statuses: [.firingSample])

        #expect(Array(history.buckets.suffix(3)) == [.firing, .firing, .firing])
    }

    @Test("A muted rule paints its breached buckets muted")
    func muted() {
        let status = AlertStatus(
            rule: AlertStatus.firingSample.rule,
            outcome: AlertOutcome(state: .muted(until: .distantFuture), shouldNotify: false),
            reading: AlertStatus.firingSample.reading
        )
        let history = AlertHistory(statuses: [status])

        #expect(history.firing == 0)
        #expect(history.armed == 0)
        #expect(history.muted == 1)
        #expect(Array(history.buckets.suffix(3)) == [.muted, .muted, .muted])
    }
}
