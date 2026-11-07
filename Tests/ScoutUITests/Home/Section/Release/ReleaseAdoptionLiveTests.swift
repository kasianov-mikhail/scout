//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import ScoutUI

struct ReleaseAdoptionLiveTests {
    @Test("Release health maps to adoption versions")
    func releases() {
        let adoption = ReleaseAdoption(releases: [ReleaseHealth].samples)

        #expect(adoption.versions.count == 5)
        #expect(adoption.versions.map(\.id) == ["3.2.0", "3.1.4", "3.1.0", "3.0.2", "2.9.9"])
        #expect(adoption.versions.map(\.shareLabel) == ["62%", "21%", "10%", "5%", "2%"])
        #expect(adoption.versions.map(\.stability.level) == [.healthy, .healthy, .watch, .atRisk, .critical])
        #expect(adoption.versions.compactMap(\.shipped) == [ReleaseHealth].samples.compactMap(\.shippedAt))
    }

    @Test("The top version follows the largest adoption")
    func top() {
        let adoption = ReleaseAdoption(releases: [ReleaseHealth].samples)

        #expect(adoption.headline == "62% on 3.2.0")
    }
}
