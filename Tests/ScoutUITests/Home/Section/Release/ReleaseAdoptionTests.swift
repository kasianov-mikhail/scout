//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import ScoutUI

struct ReleaseAdoptionTests {
    @Test("The sample splits sessions across five versions")
    func versions() {
        let versions = ReleaseAdoption.sample.versions

        #expect(versions.map(\.id) == ["3.2.0", "3.1.4", "3.1.0", "3.0.2", "2.9.9"])
        #expect(versions.map(\.shareLabel) == ["62%", "21%", "10%", "5%", "2%"])
        #expect(versions.map(\.showsLabel) == [true, true, false, false, false])
        #expect(versions.map(\.stability.level) == [.healthy, .healthy, .watch, .atRisk, .critical])
    }

    @Test("The headline reads the top version")
    func headline() {
        #expect(ReleaseAdoption.sample.headline == "62% on 3.2.0")
    }
}
