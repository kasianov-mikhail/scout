//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import ScoutUI

struct HomeSnapshotTests {
    @Test("The sample fills every home section")
    func sample() {
        let snapshot = HomeSnapshot.sample

        #expect(snapshot.alerts.buckets.count == 24)
        #expect(snapshot.users.metrics.count == 3)
        #expect(snapshot.telemetry.count == 6)
        #expect(snapshot.releases.versions.count == 5)
        #expect(snapshot.retention.count == 4)
    }

    @Test("The empty snapshot empties every home section")
    func empty() {
        let snapshot = HomeSnapshot.empty

        #expect(snapshot.alerts.isEmpty)
        #expect(snapshot.users.isEmpty)
        #expect(!snapshot.telemetry.hasValues)
        #expect(snapshot.releases.isEmpty)
        #expect(snapshot.retention.isEmpty)
    }
}
